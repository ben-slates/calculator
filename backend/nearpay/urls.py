from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('nearpay.apps.accounts.urls')),
    path('api/wallet/', include('nearpay.apps.wallets.urls')),
    path('api/transactions/', include('nearpay.apps.transactions.urls')),
    path('api/sync/', include('nearpay.apps.syncing.urls')),
]
