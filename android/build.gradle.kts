allprojects {
    repositories {
        google()
        mavenCentral()
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
    project.evaluationDependsOn(":app")
}

// Alle Plugin-Module gegen dieselbe SDK-Version bauen
// (file_picker 10 ist sonst auf android-34 fixiert).
subprojects {
    val setzeCompileSdk: (Project) -> Unit = { p ->
        p.extensions.findByType(com.android.build.api.dsl.CommonExtension::class.java)
            ?.compileSdk = 36
    }
    if (state.executed) setzeCompileSdk(this) else afterEvaluate { setzeCompileSdk(this) }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
