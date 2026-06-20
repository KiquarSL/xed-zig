package io.kiquar.plugin.zig.runner

import android.content.Context
import android.content.res.Resources
import com.koner.typst.R
import com.rk.file.FileObject
import com.rk.icons.Icon
import com.rk.runner.Runner

class ZigRunner(
    private val icon: Icon,
    private val supportedExtensions: List<String>,
) : Runner() {

    override val id = "zig.runner"

    override val label = resources.getString(R.string.compile_document)

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