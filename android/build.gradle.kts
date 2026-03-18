plugins {
    // Keep Google Services at the same version Flutter already has on the classpath.
    // Use a Crashlytics plugin version compatible with this Google Services version.
    id("com.google.gms.google-services") version "4.3.15" apply false
    // Crashlytics Gradle plugin 2.9.9 works with Google Services 4.3.15
    id("com.google.firebase.crashlytics") version "2.9.9" apply false
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
