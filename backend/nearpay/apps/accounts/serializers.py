from rest_framework import serializers

from .models import NearPayUser, OTPChallenge


class SignupSerializer(serializers.ModelSerializer):
    class Meta:
        model = NearPayUser
        fields = ('phone', 'cnic', 'public_key', 'merchant_mode')

    def create(self, validated_data):
        return NearPayUser.objects.create_user(**validated_data)


class OTPRequestSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)


class OTPVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    code = serializers.CharField(max_length=6)
