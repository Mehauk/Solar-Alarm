package com.example.solar_alarm.services

import android.content.Context
import java.io.File
import java.io.FileWriter
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class Logger(val context: Context) {
    private val LOG_FILE_NAME = "app_logs.txt"
    private val MAX_BYTES: Long = 2 * 1024 * 1024 // 2MB
    private val KEEP_BYTES: Long = 1 * 1024 * 1024 // keep last 1MB

    private fun getLogFile(): File {
        val altDir = File(context.filesDir, "app_flutter")
        return File(altDir, LOG_FILE_NAME)
    }

    private fun enforceSizeLimit(file: File) {
        try {
            if (file.exists()) {
                val len = file.length()
                if (len > MAX_BYTES) {
                    val raf = java.io.RandomAccessFile(file, "r")
                    try {
                        val start = if (len - KEEP_BYTES < 0) 0 else len - KEEP_BYTES
                        raf.seek(start)
                        val remaining = ByteArray((len - start).toInt())
                        raf.readFully(remaining)
                        file.writeBytes(remaining)
                    } finally {
                        raf.close()
                    }
                }
            }
        } catch (e: IOException) {
            println("FileLogger.enforceSizeLimit failed: $e")
        }
    }

    fun append(tag: String, message: String) {
        try {
            val file = getLogFile()
            if (!file.exists()) {
                file.createNewFile()
            }
            enforceSizeLimit(file)
            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            val timestamp = sdf.format(Date())
            FileWriter(file, true).use { fw ->
                fw.append("$timestamp $tag: $message\n")
                fw.flush()
            }
        } catch (e: IOException) {
            // fallback to FileLogger.append failed: $e")
        }
    }

    fun history(): List<String> {
        val file = getLogFile()
        if (!file.exists()) {
            return emptyList()
        }
        return file.readLines()
    }

    fun clear() {
        val file = getLogFile()
        if (file.exists()) {
            file.delete()
        }
    }
}
