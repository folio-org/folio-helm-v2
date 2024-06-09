import groovy.io.*
import org.yaml.snakeyaml.Yaml
import java.nio.file.Files
import java.nio.file.Paths

String dir = "../charts/"
List dirList = []

new File(dir).eachDir { dirList << it.name }

println(dirList.findAll { it.startsWith('mod') })

// Usage example
//def yamlData = readYamlFile("../charts/mod-oa/values.yaml")
//println(yamlData)

dirList.findAll { it.startsWith('mod') }.each { module ->
  println('=' * 15 + " ${module} " + '=' * (25 - module.length()))
  exec('helm lint', "../charts/${module}")
}

def exec(String command, String dir = null) {
  def directory = new File(dir)
  if (!directory.exists()) {
    println "Directory '${dir}' does not exist."
    return
  }

  def tokenizedCommand = command.tokenize(" ")
  def processBuilder = new ProcessBuilder(tokenizedCommand)
  processBuilder.directory(directory)
  processBuilder.redirectErrorStream(true)

  def process = processBuilder.start()
  process.inputStream.eachLine { line ->
    println line
  }
  process.waitFor()
  if (process.exitValue() != 0) {
    println "Error executing '${command}'"
  }
}

def readYamlFile(String filePath) {
  Yaml yaml = new Yaml()
  def data = null

  try {
    def content = new String(Files.readAllBytes(Paths.get(filePath)))
    data = yaml.load(content)
  } catch (Exception e) {
    println "Error reading YAML file: ${e.message}"
  }

  return data
}
