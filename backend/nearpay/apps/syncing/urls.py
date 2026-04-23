from django.urls import path

from .views import SyncTransactionsView

urlpatterns = [
    path('transactions/', SyncTransactionsView.as_view()),
]
