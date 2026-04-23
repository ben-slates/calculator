from datetime import timedelta

from django.utils import timezone

from nearpay.apps.transactions.models import Transaction


class FraudDetector:
    def score_user(self, user_id: int) -> dict:
        now = timezone.now()
        window_start = now - timedelta(minutes=5)
        tx_count = Transaction.objects.filter(sender_id=user_id, created_at__gte=window_start).count()
        rejected_count = Transaction.objects.filter(
            sender_id=user_id,
            status=Transaction.Status.REJECTED,
            created_at__gte=window_start,
        ).count()

        suspicious = tx_count > 10 or rejected_count > 3
        return {
            'tx_count_5m': tx_count,
            'rejected_5m': rejected_count,
            'suspicious': suspicious,
        }
