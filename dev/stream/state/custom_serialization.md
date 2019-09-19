# Custom Serialization for Managed State
此页面的目标是为需要为其状态使用自定义序列化的用户提供指南，包括如何提供自定义状态序列化器，以及实现允许状态模式演化的序列化器的指南和最佳实践。

如果您只是在使用Flink自己的序列化器，那么这个页面是不相关的，可以忽略。

## Using custom state serializers
注册托管操作符或键控状态时，需要使用状态描述符指定状态的名称以及关于状态类型的信息。Flink的类型序列化框架使用类型信息为状态创建适当的序列化器。

也可以完全绕过这一点，让Flink使用您自己的自定义序列化器来序列化托管状态，只需直接用您自己的类型序列化器实现实例化state描述符:

```java
public class CustomTypeSerializer extends TypeSerializer<Tuple2<String, Integer>> {...};

ListStateDescriptor<Tuple2<String, Integer>> descriptor =
    new ListStateDescriptor<>(
        "state-name",
        new CustomTypeSerializer());

checkpointedState = getRuntimeContext().getListState(descriptor);
```

## State serializers and schema evolution
本节解释与状态序列化和模式演化相关的面向用户的抽象，以及有关Flink如何与这些抽象交互的必要内部细节。

从保存点恢复时，Flink允许更改用于读写以前注册状态的序列化器，这样用户就不会被锁定到任何特定的序列化模式中。当状态恢复时，将为状态注册一个新的序列化器(即，该序列化器附带用于访问恢复作业中的状态描述符)。这个新的序列化器可能具有与前一个序列化器不同的模式。因此，在实现状态序列化器时，除了读取/写入数据的基本逻辑外，另一件需要记住的重要事情是将来如何更改序列化模式。

当谈到模式时，在这个上下文中，这个术语可以在引用状态类型的数据模型和状态类型的序列化二进制格式之间互换。一般来说，模式会在以下几种情况下发生变化:

1. 状态类型的数据模式已经发展，即从用作状态的POJO中添加或删除字段。
2. 一般来说，对数据模式进行更改后，序列化器的序列化格式需要升级。
3. 序列化程序的配置已更改。

为了使新执行具有关于已写状态模式的信息并检测模式是否已更改，在获取操作符状态的保存点时，需要将状态序列化器的快照连同状态字节一起写入。这是一个抽象的TypeSerializerSnapshot，将在下一小节中解释。

### The TypeSerializerSnapshot abstraction

```java
public interface TypeSerializerSnapshot<T> {
    int getCurrentVersion();
    void writeSnapshot(DataOuputView out) throws IOException;
    void readSnapshot(int readVersion, DataInputView in, ClassLoader userCodeClassLoader) throws IOException;
    TypeSerializerSchemaCompatibility<T> resolveSchemaCompatibility(TypeSerializer<T> newSerializer);
    TypeSerializer<T> restoreSerializer();
}
public abstract class TypeSerializer<T> {    
    
    // ...
    
    public abstract TypeSerializerSnapshot<T> snapshotConfiguration();
}
```

序列化器的typeseriizersnapshot是一个时间点信息，它作为状态序列化器的写模式的唯一真实来源，以及恢复与给定时间点相同的序列化器所需的任何附加信息。在序列化器快照恢复时应该写入和读取什么内容的逻辑在writeSnapshot和readSnapshot方法中定义。

请注意，快照本身的写模式也可能需要随着时间的推移而更改(例如，当您希望向快照添加有关序列化器的更多信息时)。为了方便实现这一点，对快照进行版本控制，并在getCurrentVersion方法中定义当前版本号。在恢复时，当从保存点读取序列化器快照时，写入快照的模式的版本将提供给readSnapshot方法，以便读实现可以处理不同的版本。

在恢复时，应该在resolveSchemaCompatibility方法中实现检测新序列化器的模式是否更改的逻辑。当在操作符的恢复执行中，用新的序列化器重新注册以前注册的状态时，通过此方法将新的序列化器提供给以前序列化器的快照。该方法返回一个表示兼容性解决方案结果的typeeseriizerschemacompatibility，它可以是以下内容之一:

1. compatible bleasis():这个结果表明新的序列化器是兼容的，这意味着新的序列化器具有与前一个序列化器相同的模式。新的序列化器有可能在resolveSchemaCompatibility方法中重新配置，使其兼容。
2. TypeSerializerSchemaCompatibility.compatibleAfterMigration():这一结果表明新的序列化器有不同的串行化模式,并可以从旧模式通过使用前面的序列化器(承认旧模式)读取字节状态对象,然后重写对象回到字节与新的序列化器(承认新模式)。
3. 不兼容():这个结果表明新的序列化器具有不同的序列化模式，但是不可能从旧模式迁移。

最后一点细节是在需要迁移的情况下如何获得前面的序列化器。序列化器的TypeSerializerSnapshot的另一个重要作用是，它充当一个工厂来恢复以前的序列化器。更具体地说，TypeSerializerSnapshot应该实现restoreSerializer方法来实例化一个序列化器实例，该实例识别前一个序列化器的模式和配置，因此可以安全地读取前一个序列化器编写的数据。

### How Flink interacts with the TypeSerializer and TypeSerializerSnapshot abstractions

最后，本节总结Flink(更具体地说，是状态后端)如何与抽象交互。根据状态后端，交互略有不同，但这与状态序列化器及其序列化器快照的实现是正交的。

堆外状态后端(例如rocksdbstateback)

1. 使用具有模式a的状态序列化器注册新状态
- 状态的已注册类型序列化器用于在每次状态访问时读取/写入状态。
- 状态用模式A编写。
2. 取一个保存点
- 序列化器快照是通过类型序列化器#snapshotConfiguration方法提取的。
- 序列化器快照被写入保存点以及已经序列化的状态字节(使用模式A)。
3. 已恢复的执行使用具有模式B的新状态序列化器重新访问已恢复的状态字节
- 恢复前一个状态序列化器的快照。
- 状态字节在恢复时不反序列化，只加载回状态后端(因此，仍然在模式A中)。
- 在接收到新的序列化器后，通过类型序列化器#resolveSchemaCompatibility将其提供给恢复的前一个序列化器的快照，以检查模式兼容性。
4. 将后端中的状态字节从模式A迁移到模式B
- 如果兼容性解决方案反映模式已经更改，并且迁移是可能的，则执行模式迁移。识别模式A的前一个状态序列化器将通过TypeSerializerSnapshot#restoreSerializer()从序列化器快照中获得，并用于将状态字节反序列化到对象，然后用新的序列化器重新编写对象，新的序列化器识别模式B来完成迁移。在继续处理之前，将所有已访问状态的条目全部迁移到一起。
- 如果分辨率表示不兼容，则状态访问将异常失败。
- 堆状态后端(例如memorystate后端、fsstate后端)


堆状态后端(例如memorystate后端、fsstate后端)

1. 使用具有模式a的状态序列化器注册新状态
- 已注册的类型序列化器由状态后端维护。

2. 取一个保存点，用模式a序列化所有状态
- 序列化器快照是通过类型序列化器#snapshotConfiguration方法提取的。
- 序列化器快照被写入保存点。
- 状态对象现在序列化到保存点，保存点用模式A编写。

3. 在还原时，将状态反序列化为堆中的对象
- 恢复前一个状态序列化器的快照。
- 前面的序列化器识别模式A，通过TypeSerializerSnapshot#restoreSerializer()从序列化器快照中获得，用于将状态字节反序列化到对象。
- 从现在开始，所有的状态都已经反序列化了。

4. 恢复的执行使用具有模式B的新状态序列化器重新访问以前的状态
- 在接收到新的序列化器后，通过类型序列化器#resolveSchemaCompatibility将其提供给恢复的前一个序列化器的快照，以检查模式兼容性。
- 如果兼容性检查表明需要迁移，那么在本例中不会发生任何事情，因为对于堆后端，所有状态都已经反序列化为对象。
- 如果分辨率表示不兼容，则状态访问将异常失败。

5. 取另一个保存点，用模式B序列化所有状态
- 与步骤2相同。，但是现在状态字节都在模式B中。


## Predefined convenient TypeSerializerSnapshot classes

Flink提供了两个抽象的基本TypeSerializerSnapshot类，它们可以用于典型的场景:SimpleTypeSerializerSnapshot和CompositeTypeSerializerSnapshot。

提供这些预定义快照作为序列化器快照的序列化器必须始终具有自己独立的子类实现。这与不跨不同序列化器共享快照类的最佳实践相对应，下一节将更详细地解释这一点。


### Implementing a SimpleTypeSerializerSnapshot

SimpleTypeSerializerSnapshot适用于没有任何状态或配置的序列化器，本质上意味着序列化器的序列化模式仅由序列化器的类定义。

当使用SimpleTypeSerializerSnapshot作为序列化器的快照类时，兼容性解析只有两种可能的结果:

- `TypeSerializerSchemaCompatibility.compatibleAsIs()`，如果新的序列化器类保持相同，或者
- `TypeSerializerSchemaCompatibility.incompatible()`，如果新的序列化器类与前一个不同。
下面是如何使用SimpleTypeSerializerSnapshot的例子，使用Flink的IntSerializer作为例子:

```java
public class IntSerializerSnapshot extends SimpleTypeSerializerSnapshot<Integer> {
    public IntSerializerSnapshot() {
        super(() -> IntSerializer.INSTANCE);
    }
}
```

反序列化器没有状态或配置。序列化格式仅由序列化器类本身定义，并且只能由另一个IntSerializer读取。因此，它适合SimpleTypeSerializerSnapshot的用例。

SimpleTypeSerializerSnapshot的基本超级构造函数期望提供相应序列化器的实例，而不管快照是当前正在恢复还是在快照期间写入。该供应商用于创建恢复序列化器，以及类型检查，以验证新序列化器是否属于预期的序列化器类。

## Implementing a CompositeTypeSerializerSnapshot

CompositeTypeSerializerSnapshot是为依赖于多个嵌套序列化器进行序列化的序列化器而设计的。

在进一步解释之前，我们将依赖于多个嵌套序列化器的序列化器称为此上下文中的“外部”序列化器。例如MapSerializer、ListSerializer、GenericArraySerializer等等。例如，考虑MapSerializer——键和值序列化器将是嵌套序列化器，而MapSerializer本身是“外部”序列化器。

在这种情况下，外部序列化器的快照还应该包含嵌套序列化器的快照，以便可以独立检查嵌套序列化器的兼容性。在解决外部序列化器的兼容性时，需要考虑每个嵌套序列化器的兼容性。

提供CompositeTypeSerializerSnapshot是为了帮助实现这些组合序列化器的快照。它处理读取和写入嵌套序列化器快照，并考虑到所有嵌套序列化器的兼容性，解决最终的兼容性结果。

下面是如何使用CompositeTypeSerializerSnapshot的例子，使用Flink的MapSerializer作为例子:

```java
public class MapSerializerSnapshot<K, V> extends CompositeTypeSerializerSnapshot<Map<K, V>, MapSerializer> {

    private static final int CURRENT_VERSION = 1;

    public MapSerializerSnapshot() {
        super(MapSerializer.class);
    }

    public MapSerializerSnapshot(MapSerializer<K, V> mapSerializer) {
        super(mapSerializer);
    }

    @Override
    public int getCurrentOuterSnapshotVersion() {
        return CURRENT_VERSION;
    }

    @Override
    protected MapSerializer createOuterSerializerWithNestedSerializers(TypeSerializer<?>[] nestedSerializers) {
        TypeSerializer<K> keySerializer = (TypeSerializer<K>) nestedSerializers[0];
        TypeSerializer<V> valueSerializer = (TypeSerializer<V>) nestedSerializers[1];
        return new MapSerializer<>(keySerializer, valueSerializer);
    }

    @Override
    protected TypeSerializer<?>[] getNestedSerializers(MapSerializer outerSerializer) {
        return new TypeSerializer<?>[] { outerSerializer.getKeySerializer(), outerSerializer.getValueSerializer() };
    }
}
```

当实现一个新的序列化器快照作为CompositeTypeSerializerSnapshot的子类时，必须实现以下三个方法:

- `#getCurrentOuterSnapshotVersion()`:这个方法定义当前外部序列化器快照的序列化二进制格式的版本。
- `#getNestedSerializers(TypeSerializer)`:给定外部序列化器，返回它的嵌套序列化器。
- `#createOuterSerializerWithNestedSerializers(TypeSerializer[])`:给定嵌套序列化器，创建外部序列化器的实例。

上面的例子是一个`CompositeTypeSerializerSnapshot`，除了嵌套序列化器的快照之外，没有额外的信息可以快照。因此，它的外部快照版本永远不需要增加。然而，其他一些序列化器包含一些额外的静态配置，需要与嵌套组件序列化器一起持久。这方面的一个例子是Flink的GenericArraySerializer，除了嵌套元素序列化器之外，它还包含数组元素类型的类作为配置。

在这些情况下，还需要在CompositeTypeSerializerSnapshot上实现另外三个方法:

- `#writeOuterSnapshot(DataOutputView)`:定义如何编写外部快照信息。
- `#readOuterSnapshot(int, DataInputView, ClassLoader)`:定义如何读取外部快照信息。
- `#isOuterSnapshotCompatible(TypeSerializer)`:检查外部快照信息是否保持相同。
默认情况下，CompositeTypeSerializerSnapshot假定没有任何外部快照信息可读/写，因此上面方法的默认实现为空。如果子类具有外部快照信息，则必须实现所有这三个方法。

下面是一个例子，使用Flink的GenericArraySerializer作为例子，说明如何将CompositeTypeSerializerSnapshot用于具有外部快照信息的复合序列化器快照:

```java
public final class GenericArraySerializerSnapshot<C> extends CompositeTypeSerializerSnapshot<C[], GenericArraySerializer> {

    private static final int CURRENT_VERSION = 1;

    private Class<C> componentClass;

    public GenericArraySerializerSnapshot() {
        super(GenericArraySerializer.class);
    }

    public GenericArraySerializerSnapshot(GenericArraySerializer<C> genericArraySerializer) {
        super(genericArraySerializer);
        this.componentClass = genericArraySerializer.getComponentClass();
    }

    @Override
    protected int getCurrentOuterSnapshotVersion() {
        return CURRENT_VERSION;
    }

    @Override
    protected void writeOuterSnapshot(DataOutputView out) throws IOException {
        out.writeUTF(componentClass.getName());
    }

    @Override
    protected void readOuterSnapshot(int readOuterSnapshotVersion, DataInputView in, ClassLoader userCodeClassLoader) throws IOException {
        this.componentClass = InstantiationUtil.resolveClassByName(in, userCodeClassLoader);
    }

    @Override
    protected boolean isOuterSnapshotCompatible(GenericArraySerializer newSerializer) {
        return this.componentClass == newSerializer.getComponentClass();
    }

    @Override
    protected GenericArraySerializer createOuterSerializerWithNestedSerializers(TypeSerializer<?>[] nestedSerializers) {
        TypeSerializer<C> componentSerializer = (TypeSerializer<C>) nestedSerializers[0];
        return new GenericArraySerializer<>(componentClass, componentSerializer);
    }

    @Override
    protected TypeSerializer<?>[] getNestedSerializers(GenericArraySerializer outerSerializer) {
        return new TypeSerializer<?>[] { outerSerializer.getComponentSerializer() };
    }
}
```

在上面的代码片段中有两件重要的事情需要注意。首先，由于这个CompositeTypeSerializerSnapshot实现具有作为快照的一部分编写的外部快照信息，所以当外部快照信息的序列化格式发生更改时，由getCurrentOuterSnapshotVersion()定义的外部快照版本必须被选中。

其次，注意我们如何避免在编写组件类时使用Java序列化，只编写类名并在读取快照时动态加载它。在编写序列化器快照的内容时避免Java序列化通常是一个很好的实践。关于这一点的更多细节将在下一节中讨论。

## Implementation notes and best practices
### 1. Flink通过用类名实例化序列化器快照来恢复它们

序列化器的快照是已注册状态如何序列化的唯一真实来源，它作为读取保存点中的状态的入口点。为了能够恢复和访问以前的状态，必须能够恢复以前状态序列化器的快照。

Flink通过首先实例化TypeSerializerSnapshot及其类名(连同快照字节一起编写)来恢复序列化器快照。因此，为了避免意外的类名更改或实例化失败，TypeSerializerSnapshot类应该:

- 避免实现为匿名类或嵌套类，
- 是否有一个用于实例化的公共空构造函数

### 2. 避免在不同的序列化器之间共享相同的TypeSerializerSnapshot类

由于模式兼容性检查遍历序列化器快照，如果多个序列化器返回与快照相同的TypeSerializerSnapshot类，则会使TypeSerializerSnapshot#resolveSchemaCompatibility和TypeSerializerSnapshot#restoreSerializer()方法的实现复杂化。

这也是一个糟糕的关注点分离;一个序列化器的序列化模式、配置以及如何恢复它，应该合并到它自己专用的TypeSerializerSnapshot类中。

### 3.避免对序列化器快照内容使用Java序列化

在编写持久序列化器快照的内容时，根本不应该使用Java序列化。例如，序列化器需要将目标类型的类作为快照的一部分持久存储。关于类的信息应该通过编写类名来持久化，而不是使用Java直接序列化类。读取快照时，将读取类名，并使用该类名动态加载类。

这种做法确保序列化器快照总是可以安全地读取。在上面的示例中，如果使用Java序列化持久化类型类，那么一旦类实现发生更改，快照可能就不再可读，并且根据Java序列化的具体情况，快照也不再是二进制兼容的。

## Migrating from deprecated serializer snapshot APIs before Flink 1.7
本节介绍如何从Flink 1.7之前存在的序列化器和序列化器快照迁移API。

在Flink 1.7之前，序列化器快照是作为typeseriizerconfigsnapshot实现的(现在已经不推荐使用这个配置，将来会被新的TypeSerializerSnapshot接口完全替代)。此外，序列化器模式兼容性检查的职责存在于类型序列化器中，在类型序列化器#ensureCompatibility(typeseriizerconfigsnapshot)方法中实现。

新抽象和旧抽象之间的另一个主要区别是，废弃的TypeSerializerConfigSnapshot没有实例化前一个序列化器的功能。因此，如果序列化器仍然返回TypeSerializerConfigSnapshot的子类作为其快照，则序列化器实例本身将始终使用Java序列化写入保存点，以便在恢复时可以使用前面的序列化器。这是非常不可取的，因为恢复作业是否成功容易受到前一个序列化器类的可用性的影响，或者一般来说，是否可以在恢复时使用Java序列化读取序列化器实例。这意味着您的状态只能使用相同的序列化器，并且一旦您想要升级序列化器类或执行模式迁移，就会出现问题。

为了保证将来的安全性，并具有迁移状态序列化器和模式的灵活性，强烈建议从旧的抽象迁移。具体步骤如下:

1. 实现一个新的TypeSerializerSnapshot子类。这将是您的序列化程序的新快照。
2. 在TypeSerializer#snapshotConfiguration()方法中返回新的typeseriizersnapshot作为序列化器的序列化器快照。
3. 从Flink 1.7之前存在的保存点恢复作业，然后再次获取保存点。注意，在这个步骤中，序列化器的旧typeseriizerconfigsnapshot必须仍然存在于类路径中，并且不能删除TypeSerializer#ensureCompatibility(TypeSerializerConfigSnapshot)方法的实现。这个过程的目的是用用于序列化器的新实现的TypeSerializerSnapshot替换在旧保存点中编写的typeseriizerconfigsnapshot。
4. 使用Flink 1.7获得保存点后，保存点将包含TypeSerializerSnapshot作为状态序列化器快照，序列化器实例将不再写入保存点。现在，可以安全地删除旧抽象的所有实现(从序列化器中删除旧的typeseriizerconfigsnapshot实现以及TypeSerializer#ensureCompatibility(TypeSerializerConfigSnapshot))。

