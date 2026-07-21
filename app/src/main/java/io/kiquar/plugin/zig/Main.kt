package io.kiquar.plugin.zig

import android.app.Activity
import android.os.Bundle
import androidx.annotation.Keep
import com.rk.extension.ExtensionAPI
import com.rk.extension.ExtensionContext
import com.rk.file.child
import com.rk.lsp.LspRegistry
import com.rk.runner.RunnerManager
import com.rk.utils.getTempDir
import io.kiquar.plugin.zig.runner.ZigBuildRunner
import io.kiquar.plugin.zig.runner.ZigRunner
import kotlinx.coroutines.runBlocking
import java.io.File
import kotlin.io.writeText

@Keep
@Suppress("unused")
class Main(context: ExtensionContext) : ExtensionAPI(context) {

    private var zigServer: ZigServer? = null
    private var zigRunner: ZigRunner? = null
    private var zigBuildRunner: ZigBuildRunner? = null

    override fun onInstalled() {}

    override fun onLoad() {}

    override fun onExtensionLoaded() {
        zigServer = ZigServer(
            installScript = acquireLspInstallScript()
        ).also {
            LspRegistry.registerServer(it)
        }
        zigRunner = ZigRunner().also {
            RunnerManager.registerRunner(it)
        }
        zigBuildRunner = ZigBuildRunner().also {
            RunnerManager.registerRunner(it)
        }
    }

    override fun onUpdate() {
        dispose()
    }

    override fun onUninstalled() {
        context.currentActivity?.let { activity ->
            runBlocking {
                val isInstalled = zigServer?.isInstalled(activity) ?: false
                if (isInstalled) {
                    zigServer?.uninstall(activity)
                }
            }
        }
        dispose()
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityDestroyed(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}
    override fun onActivityResumed(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}

    private fun dispose() {
        zigServer?.let {
            LspRegistry.unregisterServer(it)
        }
        zigRunner?.let {
            RunnerManager.unregisterRunner(it)
        }
        zigBuildRunner?.let {
            RunnerManager.unregisterRunner(it)
        }
    }

    private fun acquireLspInstallScript(): File {
        val script = context.assets.open("zig-installer.sh").bufferedReader().use { it.readText() }
        return getTempDir().child("zig-installer.sh").also {
            it.writeText(script)
            it.setExecutable(true)
        }
    }
}
