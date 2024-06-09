import java.nio.file.Files
import java.nio.file.Paths

String file = 'NOTES.txt'
String chartsDir = "../charts"

List dirList = []
new File(chartsDir).eachDir { dirList << it.name }

dirList.findAll { it.startsWith('mod') }.each { module ->
  String targetFile = "${chartsDir}/${module}/templates/${file}"
  if (new File(targetFile).exists()) {
    Files.delete(Paths.get(targetFile))
  }
  Files.copy(Paths.get("./${file}"), Paths.get(targetFile))
}
