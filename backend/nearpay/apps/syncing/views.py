from django.db import transaction as db_transaction
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from nearpay.apps.transactions.models import Transaction
from nearpay.apps.transactions.serializers import VerificationSerializer
from nearpay.apps.wallets.models import Wallet


class SyncTransactionsView(APIView):
    permission_classes = [IsAuthenticated]

    @db_transaction.atomic
    def post(self, request):
        serializer = VerificationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if Transaction.objects.filter(nonce=data['nonce']).exists():
            return Response({'detail': 'Replay/double-spend detected'}, status=status.HTTP_409_CONFLICT)

        sender_wallet, _ = Wallet.objects.select_for_update().get_or_create(user_id=data['sender_id'])
        receiver_wallet, _ = Wallet.objects.select_for_update().get_or_create(user_id=data['receiver_id'])

        if sender_wallet.balance < data['amount']:
            return Response({'detail': 'Insufficient reconciled balance'}, status=status.HTTP_409_CONFLICT)

        tx = Transaction.objects.create(
            sender_id=data['sender_id'],
            receiver_id=data['receiver_id'],
            amount=data['amount'],
            nonce=data['nonce'],
            signature=data['signature'],
            timestamp=data['timestamp'],
            status=Transaction.Status.CONFIRMED,
        )

        sender_wallet.balance -= data['amount']
        receiver_wallet.balance += data['amount']
        sender_wallet.save(update_fields=['balance'])
        receiver_wallet.save(update_fields=['balance'])

        return Response({'transaction_id': tx.id}, status=status.HTTP_201_CREATED)
