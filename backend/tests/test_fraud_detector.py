from django.utils import timezone

from nearpay.apps.accounts.models import NearPayUser
from nearpay.apps.fraud.service import FraudDetector
from nearpay.apps.transactions.models import Transaction


def test_fraud_detector_marks_high_velocity(db):
    sender = NearPayUser.objects.create(phone='111', cnic='1')
    receiver = NearPayUser.objects.create(phone='222', cnic='2')

    for idx in range(11):
        Transaction.objects.create(
            sender=sender,
            receiver=receiver,
            amount=100,
            nonce=f'00000000-0000-0000-0000-{idx:012d}',
            signature='aa',
            timestamp=timezone.now(),
        )

    report = FraudDetector().score_user(sender.id)
    assert report['suspicious'] is True
