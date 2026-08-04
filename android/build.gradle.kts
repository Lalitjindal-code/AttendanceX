allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core-ktx:1.6.0")
            force("androidx.core:core:1.6.0")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val getNamespace = androidExt.javaClass.methods.find { it.name == "getNamespace" }
                val currentNamespace = getNamespace?.invoke(androidExt) as? String
                if (currentNamespace == null || currentNamespace.isEmpty()) {
                    val setNamespace = androidExt.javaClass.methods.find { it.name == "setNamespace" }
                    if (setNamespace != null) {
                        var groupStr = project.group.toString()
                        if (groupStr.isEmpty() || groupStr == "null") {
                            groupStr = "dev.flutter.plugin." + project.name.replace("-", "_")
                        }
                        setNamespace.invoke(androidExt, groupStr)
                    }
                }
            } catch (e: Exception) {
                // Ignore
            }
        }
    }
    project.evaluationDependsOn(":app")
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
