import uuid

import pytest
from rest_framework.test import APIClient

from nearpay.apps.accounts.models import NearPayUser
from nearpay.apps.wallets.models import Wallet


@pytest.mark.django_db
def test_sync_rejects_double_spend():
    sender = NearPayUser.objects.create(phone='333', cnic='3')
    receiver = NearPayUser.objects.create(phone='444', cnic='4')
    Wallet.objects.create(user=sender, balance=10_000)
    Wallet.objects.create(user=receiver, balance=0)

    client = APIClient()
    client.force_authenticate(user=sender)

    nonce = uuid.uuid4()
    payload = {
        'sender_id': sender.id,
        'receiver_id': receiver.id,
        'amount': 1000,
        'timestamp': '2026-01-01T00:00:00Z',
        'nonce': str(nonce),
        'signature': 'abcd',
    }

    first = client.post('/api/sync/transactions/', payload, format='json')
    second = client.post('/api/sync/transactions/', payload, format='json')

    assert first.status_code == 201
    assert second.status_code == 409
