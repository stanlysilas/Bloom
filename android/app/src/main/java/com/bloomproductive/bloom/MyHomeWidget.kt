package com.bloomproductive.bloom

import android.annotation.SuppressLint
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore

/**
 * Implementation of App Widget functionality.
 */
class MyHomeWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.my_home_widget)
        fetchTasksFromFirestore(context, appWidgetManager, appWidgetId, views)
    }

    @SuppressLint("ResourceType")
    private fun fetchTasksFromFirestore(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, views: RemoteViews) {
        val firestore = FirebaseFirestore.getInstance()
        val user = FirebaseAuth.getInstance()

        // Fetch only "pending" tasks from Firestore
        firestore.collection("users")
            .document(user.currentUser!!.uid)
            .collection("tasks")
            .whereEqualTo("isCompleted", false)
            .get()
            .addOnSuccessListener { querySnapshot ->
                  val numberOfTasksPending = querySnapshot.documents.size
                val tasks = querySnapshot.documents.map { it.getString("taskName") ?: "No Task" }
                val tasksText = if (tasks.isNotEmpty()) tasks.joinToString("\n") else "No pending tasks"

                // Update the widget content
                views.setTextViewText(R.id.appwidget_text, "Pending tasks: ${numberOfTasksPending}")
                views.setTextViewText(R.string.tasksText1, tasksText)

                // Apply the updated views to the widget
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
            .addOnFailureListener {
                // Handle errors
                views.setTextViewText(R.id.appwidget_text, "Error loading tasks")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    val widgetText = context.getString(R.string.appwidget_text)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.my_home_widget)
    views.setTextViewText(R.id.appwidget_text, widgetText)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}