import random

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import NearPayUser, OTPChallenge
from .serializers import OTPRequestSerializer, OTPVerifySerializer, SignupSerializer


class SignupView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response({'id': user.id, 'phone': user.phone}, status=status.HTTP_201_CREATED)


class RequestOTPView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data['phone']
        code = f'{random.randint(100000, 999999)}'
        OTPChallenge.objects.create(phone=phone, code=code)
        # Twilio integration point.
        return Response({'status': 'sent', 'code_for_dev': code})


class VerifyOTPView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        challenge = OTPChallenge.objects.filter(
            phone=serializer.validated_data['phone'],
            code=serializer.validated_data['code'],
            consumed=False,
        ).order_by('-created_at').first()

        if not challenge:
            return Response({'detail': 'Invalid OTP'}, status=status.HTTP_400_BAD_REQUEST)

        challenge.consumed = True
        challenge.save(update_fields=['consumed'])

        user, _ = NearPayUser.objects.get_or_create(
            phone=serializer.validated_data['phone'], defaults={'cnic': 'PENDING_KYC'}
        )
        refresh = RefreshToken.for_user(user)
        return Response({'refresh': str(refresh), 'access': str(refresh.access_token)})
