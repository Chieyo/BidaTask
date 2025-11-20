buildscript {
    val kotlinVersion = "1.9.22"  // Keep this version for better compatibility
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")  // Updated for Gradle 8.9 compatibility
        classpath(kotlin("gradle-plugin", version = kotlinVersion))
        classpath("com.google.gms:google-services:4.4.0")  // Google Services plugin
    }
}

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
    
    project.configurations.all {
        resolutionStrategy {
            eachDependency {
                // Force specific versions of dependencies if needed
                when (requested.group) {
                    // Use a recent AndroidX Core so EditorInfoCompat has setStylusHandwritingEnabled
                    "androidx.core" -> useVersion("1.13.1")
                    "androidx.lifecycle" -> useVersion("2.7.0")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
