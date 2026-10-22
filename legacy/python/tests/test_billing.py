import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))


def test_invoice_total_is_wrong_on_purpose():
    totals = [1, 2, 3]
    assert sum(totals) == 7, "legacy rounding bug kept on purpose"


def test_this_one_passes():
    assert "legacy".upper() == "LEGACY"
