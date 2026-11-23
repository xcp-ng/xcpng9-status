"""Project-specific capellambse validation rules.

Importing this module registers the rules; they then run as part of
``model.validate()`` alongside capellambse's own.
"""

from capellambse import metamodel as mm
from capellambse.extensions.validation import _validate
from capellambse.extensions.validation._validate import rule


def _is_operational(obj):
    return isinstance(obj.layer, mm.oa.OperationalAnalysis)


def _carriers(model, exchange):
    return [
        cm
        for cm in model.search(mm.oa.CommunicationMean)
        if exchange in cm.allocated_functional_exchanges
    ]


@rule(
    category=_validate.Category.REQUIRED,
    types=[mm.fa.FunctionalExchange],
    id="XCPNG-OA-001",
    name="Interaction between entities is carried by a communication mean",
    rationale=(
        "An interaction between activities performed by different entities"
        " or actors refines what those entities exchange: it must be carried"
        " by (allocated to) a communication mean between them, so that the"
        " activity-level view stays consistent with the entity-level one."
    ),
    action=(
        "Allocate the interaction to the communication mean between the"
        " performers of its two activities (`trace \"<COMM>\" allocates"
        " \"<INTER>\"`), adding that communication mean if missing."
    ),
)
def interaction_carried_by_communication_mean(obj) -> bool:
    if not _is_operational(obj):
        return True
    ends = {obj.source.owner.uuid, obj.target.owner.uuid}
    carriers = _carriers(obj._model, obj)
    if len(ends) == 1:
        # Within one entity: nothing to carry it.
        return not carriers
    return bool(carriers) and all({cm.source.uuid, cm.target.uuid} == ends for cm in carriers)
