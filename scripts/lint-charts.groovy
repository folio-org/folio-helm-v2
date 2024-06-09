String chartsDir = "../charts"
List dirList = []

new File(chartsDir).eachDir { dirList << it.name }

dirList.findAll { it.startsWith('mod') }.each { module ->
  println('=' * 15 + " ${module} " + '=' * (30 - module.length()))
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
