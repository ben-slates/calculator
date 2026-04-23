import json

from rest_framework import serializers

from .models import Transaction


class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = (
            'id',
            'sender',
            'receiver',
            'amount',
            'nonce',
            'signature',
            'timestamp',
            'status',
        )


class VerificationSerializer(serializers.Serializer):
    sender_id = serializers.IntegerField()
    receiver_id = serializers.IntegerField()
    amount = serializers.IntegerField(min_value=1)
    timestamp = serializers.DateTimeField()
    nonce = serializers.UUIDField()
    signature = serializers.CharField()

    def canonical_payload(self) -> bytes:
        payload = {
            'sender_id': self.validated_data['sender_id'],
            'receiver_id': self.validated_data['receiver_id'],
            'amount': self.validated_data['amount'],
            'timestamp': self.validated_data['timestamp'].astimezone().isoformat(),
            'nonce': str(self.validated_data['nonce']),
        }
        return json.dumps(payload, separators=(',', ':')).encode('utf-8')
