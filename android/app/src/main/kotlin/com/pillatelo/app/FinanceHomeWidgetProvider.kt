package com.pillatelo.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Proveedor del widget de pantalla de inicio para Pillatelo.
 * Permite visualizar el saldo y último registro rápidamente.
 */
class FinanceHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.finance_widget_layout).apply {
                // Leer datos guardados desde Flutter via home_widget
                val saldoTotal = widgetData.getString("saldo_total", "0.00") ?: "0.00"
                val ultimoRegistro = widgetData.getString("ultimo_registro", "Sin registros") ?: "Sin registros"

                setTextViewText(R.id.tv_saldo, "Bs. $saldoTotal")
                setTextViewText(R.id.tv_ultimo_registro, ultimoRegistro)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
