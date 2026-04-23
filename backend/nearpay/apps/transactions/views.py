import hashlib
from datetime import timedelta

import ecdsa
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from nearpay.apps.accounts.models import NearPayUser

from .models import Transaction
from .serializers import VerificationSerializer


class TransactionHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        txs = Transaction.objects.filter(sender=request.user)[:100]
        data = [
            {
                'id': tx.id,
                'amount': tx.amount,
                'status': tx.status,
                'created_at': tx.created_at,
            }
            for tx in txs
        ]
        return Response(data)


class VerifyTransactionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = VerificationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        if Transaction.objects.filter(nonce=data['nonce']).exists():
            return Response({'detail': 'Replay nonce'}, status=status.HTTP_409_CONFLICT)

        if abs(timezone.now() - data['timestamp']) > timedelta(minutes=10):
            return Response({'detail': 'Stale timestamp'}, status=status.HTTP_400_BAD_REQUEST)

        sender = NearPayUser.objects.get(id=data['sender_id'])
        receiver = NearPayUser.objects.get(id=data['receiver_id'])

        payload = serializer.canonical_payload()
        digest = hashlib.sha256(payload).digest()

        try:
            verifying_key = ecdsa.VerifyingKey.from_string(
                bytes.fromhex(sender.public_key), curve=ecdsa.SECP256k1
            )
            signature = bytes.fromhex(data['signature'])
            if not verifying_key.verify_digest(signature, digest):
                raise ValueError('Bad signature')
        except Exception:
            return Response({'detail': 'Invalid signature'}, status=status.HTTP_400_BAD_REQUEST)

        tx = Transaction.objects.create(
            sender=sender,
            receiver=receiver,
            amount=data['amount'],
            nonce=data['nonce'],
            signature=data['signature'],
            timestamp=data['timestamp'],
            status=Transaction.Status.CONFIRMED,
        )
        return Response({'transaction_id': tx.id}, status=status.HTTP_201_CREATED)
