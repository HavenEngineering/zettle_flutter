val githubToken: String = providers.environmentVariable("GITHUB_TOKEN").orNull
    ?: throw GradleException(
        "GITHUB_TOKEN environment variable is not set. " +
        "A GitHub personal access token with read:packages scope is required " +
        "to resolve the Zettle SDK from GitHub Packages. " +
        "See https://github.com/iZettle/sdk-android for details."
    )

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.pkg.github.com/iZettle/sdk-android")
            credentials(HttpHeaderCredentials::class) {
                name = "Authorization"
                value = "Bearer $githubToken"
            }
            authentication {
                create<HttpHeaderAuthentication>("header")
            }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
