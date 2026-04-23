from django.conf import settings
from django.db import models


class Wallet(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    balance = models.BigIntegerField(default=0)
    offline_spending_limit = models.BigIntegerField(default=5000)
    updated_at = models.DateTimeField(auto_now=True)
