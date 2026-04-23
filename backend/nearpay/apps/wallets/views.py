from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Wallet


class BalanceView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        wallet, _ = Wallet.objects.get_or_create(user=request.user)
        return Response(
            {
                'user_id': request.user.id,
                'balance': wallet.balance,
                'offline_spending_limit': wallet.offline_spending_limit,
            }
        )
