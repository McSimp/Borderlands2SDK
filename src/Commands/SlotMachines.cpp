#include "BL2SDK/BL2SDK.h"
#include "Logging/Logging.h"
#include "Commands/ConCommand.h"

enum SlotsPrizes
{
	PRIZE_COMMON,
	PRIZE_UNCOMMON,
	PRIZE_RARE,
	PRIZE_VERYRARE,
	PRIZE_LEGENDARY,
	PRIZE_ERID1,
	PRIZE_ERID2,
	PRIZE_ERID3,
	PRIZE_CASH,
	PRIZE_GRENADE,
	PRIZE_SKIN,
	PRIZE_NOTHING
};

bool ready = false;
std::map<std::string, SlotsPrizes> stringToPrizeMap;
TArray<float> defaultConditions;
std::string usage;

UBehavior_RandomBranch* GetRandomGenInstance()
{
	for (int i = 0; i < UObject::GObjObjects()->Count; i++) 
	{
		UObject* Object = UObject::GObjObjects()->Data[i];

		if(!Object || ! Object->IsA(UBehavior_RandomBranch::StaticClass()) )
			continue;

		UBehavior_RandomBranch* randBranch = (UBehavior_RandomBranch*)Object;
		if(randBranch->Conditions.Count == 12) // The slots have 12 conditions. Hoping nothing else does
		{
			return randBranch;
		}
	}
	return NULL;
}

void SetChanceToMax(SlotsPrizes index)
{
	UBehavior_RandomBranch* rb = GetRandomGenInstance();
	if(rb == NULL)
	{
		Logging::Log("Random generator instance not found\n");
		return;
	}

	for(int i = 0; i < rb->Conditions.Count; i++)
	{
		if(i != index)
		{
			rb->Conditions.Data[i] = 0.0f; // Give this condition 0% chance
		}
		else
		{
			rb->Conditions.Data[i] = 100.0f; // Give the one we want 100%
		}
	}

	Logging::Log("Slots rigged successfully\n");
}

bool Initialize()
{
	UBehavior_RandomBranch* rb = GetRandomGenInstance();
	if(rb == NULL)
	{
		Logging::Log("Random generator instance not found\n");
		return false;
	}

	stringToPrizeMap.insert(std::make_pair("Common", PRIZE_COMMON));
	stringToPrizeMap.insert(std::make_pair("Uncommon", PRIZE_UNCOMMON));
	stringToPrizeMap.insert(std::make_pair("Rare", PRIZE_RARE));
	stringToPrizeMap.insert(std::make_pair("Veryrare", PRIZE_VERYRARE));
	stringToPrizeMap.insert(std::make_pair("Legendary", PRIZE_LEGENDARY));
	stringToPrizeMap.insert(std::make_pair("Erid1", PRIZE_ERID1));
	stringToPrizeMap.insert(std::make_pair("Erid2", PRIZE_ERID2));
	stringToPrizeMap.insert(std::make_pair("Erid3", PRIZE_ERID3));
	stringToPrizeMap.insert(std::make_pair("Cash", PRIZE_CASH));
	stringToPrizeMap.insert(std::make_pair("Grenade", PRIZE_GRENADE));
	stringToPrizeMap.insert(std::make_pair("Skin", PRIZE_SKIN));
	stringToPrizeMap.insert(std::make_pair("Nothing", PRIZE_NOTHING));

	defaultConditions = TArray<float>();
	
	// Store the original conditions. TODO: Do this better by doing a memory copy.
	for(int i = 0; i < rb->Conditions.Count; i++)
	{
		defaultConditions.Add(rb->Conditions.Data[i]);
	}

	usage = "Usage: RigSlots <prize>\nPrizes: Common, Uncommon, Rare, Veryrare, Legendary, Erid1, Erid2, Erid3, Cash, Grenade, Skin, Nothing\n";

	return true;
}

CON_COMMAND(RigSlots)
{
	if(!ready)
	{
		if(!Initialize())
		{
			return;
		}
		ready = true;
	}

	if(args.size() < 2)
	{
		// Display help. This person obviously needs help.
		Logging::Log("%s", usage.c_str());
		return;
	}

	std::map<std::string, SlotsPrizes>::iterator iS2P = stringToPrizeMap.find(args[1]);
	if(iS2P != stringToPrizeMap.end())
	{
		SetChanceToMax(iS2P->second);	
	}
	else
	{
		Logging::Log("%s", usage.c_str());
	}
}

CON_COMMAND(ResetSlots)
{
	if(!ready)
	{
		if(!Initialize())
		{
			return;
		}
		ready = true;
	}

	UBehavior_RandomBranch* rb = GetRandomGenInstance();
	if(rb == NULL)
	{
		Logging::Log("Random generator instance not found\n");
		return;
	}

	for(int i = 0; i < rb->Conditions.Count; i++)
	{
		rb->Conditions.Data[i] = defaultConditions.Data[i];
	}

	Logging::Log("Slot probabilities reset\n");
}