package io.kiquar.plugin.zig.runner

import android.content.Context
import android.content.res.Resources
import com.koner.typst.R
import com.rk.file.FileObject
import com.rk.icons.Icon
import com.rk.runner.Runner
import com.rk.exec.launchTerminal
import com.rk.file.BuiltinFileType

class ZigRunner(
    private val icon: Icon = BuiltinFileType.ZIG.icon,
    private val supportedExtensions: List<String>,
) : Runner() {

    override val id = "zig.runner"

    override val label = "Zig run"

    override fun getIcon(context: Context) = icon

    override fun matcher(fileObject: FileObject): Boolean {
        return supportedExtensions.contains(fileObject.getExtension())
    }

    override suspend fun run(context: Context, fileObject: FileObject) {
        val workingDir = fileObject.getParentFile()?.getAbsolutePath()
        val activity = MainActivity.instance ?: return

        launchTerminal(
            context = activity,
            terminalCommand = TerminalCommand(
                exe = "zig",
                args = arrayOf("run", "$1"),
                id = id,
                workingDir = workingDir,
            ),
        )
    }

    override suspend fun isRunning() = false

    override suspend fun stop() {}
}