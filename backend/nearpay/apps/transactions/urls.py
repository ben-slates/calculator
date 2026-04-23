from django.urls import path

from .views import TransactionHistoryView, VerifyTransactionView

urlpatterns = [
    path('history/', TransactionHistoryView.as_view()),
    path('verify/', VerifyTransactionView.as_view()),
]
