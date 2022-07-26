import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.DataFlow2
import semmle.code.java.dataflow.DataFlow3
import semmle.code.java.dataflow.DataFlow4
import semmle.code.java.dataflow.DataFlow5
import semmle.code.java.dataflow.DataFlow6

abstract class DebugNode extends DataFlow::Node {
  abstract string getConfigName();

  abstract string getNodeType();
  }

class DebugSource extends DebugNode {
  string configName;

  DebugSource() {
    configName.(DataFlow::Configuration).isSource(this)
    or
    configName.(DataFlow2::Configuration).isSource(this)
    or
    configName.(DataFlow3::Configuration).isSource(this)
    or
    configName.(DataFlow4::Configuration).isSource(this)
    or
    configName.(DataFlow5::Configuration).isSource(this)
    or
    configName.(DataFlow6::Configuration).isSource(this)
  }

  override string getConfigName() { result = configName }

  override string getNodeType() { result = "source" }
}

class DebugSink extends DebugNode {
  string configName;

  DebugSink() {
    configName.(DataFlow::Configuration).isSink(this)
    or
    configName.(DataFlow2::Configuration).isSink(this)
    or
    configName.(DataFlow3::Configuration).isSink(this)
    or
    configName.(DataFlow4::Configuration).isSink(this)
    or
    configName.(DataFlow5::Configuration).isSink(this)
    or
    configName.(DataFlow6::Configuration).isSink(this)
  }

  override string getConfigName() { result = configName }

  override string getNodeType() { result = "sink" }
}

string configNames() {
  result instanceof DataFlow::Configuration
  or
  result instanceof DataFlow2::Configuration
  or
  result instanceof DataFlow3::Configuration
  or
  result instanceof DataFlow4::Configuration
  or
  result instanceof DataFlow5::Configuration
  or
  result instanceof DataFlow6::Configuration
}

string nodeTypes() { result = ["source", "sink"] }

DebugNode debugNodes(string configName, string type) {
  configName = result.getConfigName() and type = result.getNodeType()
}

module verbose{
  query predicate sources(string loc, string configName) {
    loc =
      any(DebugSource ds | ds.getConfigName() = configName).getLocation().getFile().getRelativePath()
  }

  query predicate sinks(string loc, string configName) {
    loc =
      any(DebugSink ds | ds.getConfigName() = configName).getLocation().getFile().getRelativePath()
  }
}

query predicate diagnostics(string info, int verbosity) {
  verbosity = 0 and
  exists(string configName, int source_count, int sink_count |
    configName = configNames() and
    source_count = count(DebugSource ds | ds.getConfigName() = configName) and
    sink_count = count(DebugSink ds | ds.getConfigName() = configName) and
    info = "\"" + configName + "\": " + source_count.toString() + " sources, " + sink_count.toString() + " sinks"
  )
}
