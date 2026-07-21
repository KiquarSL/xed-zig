package io.kiquar.plugin.zig.runner

import android.app.Activity
import android.content.Context
import com.rk.file.BuiltinFileType
import com.rk.file.FileObject
import com.rk.exec.TerminalCommand
import com.rk.exec.launchTerminal
import com.rk.icons.Icon
import com.rk.runner.Runner

class ZigBuildRunner(
    val icon: Icon? = BuiltinFileType.ZIG.icon,
) : Runner() {

    override val id = "zig.build.run"
    override val label = "Zig Build Run"

    override fun getIcon(context: Context) = icon

    override fun matcher(fileObject: FileObject): Boolean {
        val name = fileObject.getName()
        return name == "build.zig" || name == "build.zig.zon"
    }

    override suspend fun run(activity: Activity, fileObject: FileObject) {
        val workingDir = fileObject.getParentFile()?.getAbsolutePath()
        launchTerminal(
            activity = activity,
            terminalCommand = TerminalCommand(
                exe = "\$HOME/.local/zig/zig",
                args = arrayOf("build", "run"),
                id = id,
                workingDir = workingDir,
            ),
        )
    }

    override suspend fun isRunning() = false

    override suspend fun stop() {}
}
