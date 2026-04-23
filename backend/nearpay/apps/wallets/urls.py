from django.urls import path

from .views import BalanceView

urlpatterns = [
    path('balance/', BalanceView.as_view()),
]
