from django.urls import path

from .views import RequestOTPView, SignupView, VerifyOTPView

urlpatterns = [
    path('signup/', SignupView.as_view()),
    path('request-otp/', RequestOTPView.as_view()),
    path('verify-otp/', VerifyOTPView.as_view()),
]
