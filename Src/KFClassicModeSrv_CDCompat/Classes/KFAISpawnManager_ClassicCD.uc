class KFAISpawnManager_ClassicCD extends CD_SpawnManager;

var CD_SpawnManager OriginalSpawnManager;
var ClassicMode ControllerMutator;

function Initialize()
{
	if( OriginalSpawnManager == None )
	{
		OriginalSpawnManager = new(Outer) class<CD_SpawnManager>(SpawnManagerClasses[GameLength]);
		OriginalSpawnManager.Initialize();
	}
	else OriginalSpawnManager.Initialize();
}

function Update()
{
	local array<class<KFPawn_Monster> > SpawnList;
	local int SpawnSquadResult;

	if ( OriginalSpawnManager.IsFinishedSpawning() || !IsWaveActive() )
	{
		return;
	}
    
    OriginalSpawnManager.bTemporarilyEndless = bTemporarilyEndless;

	OriginalSpawnManager.TotalWavesActiveTime += SpawnPollFloat;
	OriginalSpawnManager.TimeUntilNextSpawn -= SpawnPollFloat;

	OriginalSpawnManager.CohortZedsSpawned = 0;
	OriginalSpawnManager.CohortSquadsSpawned = 0;
	OriginalSpawnManager.CohortVolumeIndex = 0;

	while ( OriginalSpawnManager.ShouldAddAI() )
	{
		SpawnList = OriginalSpawnManager.GetNextSpawnList();
		if( ControllerMutator != None )
			ControllerMutator.AdjustSpawnList(SpawnList);
			
		SpawnSquadResult = OriginalSpawnManager.SpawnSquad( SpawnList );
		NumAISpawnsQueued += SpawnSquadResult;
		OriginalSpawnManager.CohortZedsSpawned += SpawnSquadResult;
		
		if ( 0 == SpawnSquadResult || 0 >= Outer.CohortSizeInt )
			break;
			
		OriginalSpawnManager.CohortSquadsSpawned += 1;
	}

	if ( 0 < OriginalSpawnManager.CohortZedsSpawned )
	{
		OriginalSpawnManager.TimeUntilNextSpawn = OriginalSpawnManager.CalcNextGroupSpawnTime();
		
		SpawnEventsThisWave += 1;
		LatestSpawnTimestamp = Outer.Worldinfo.RealTimeSeconds;

		if ( 0 > FirstSpawnTimestamp )
		{
			FirstSpawnTimestamp = LatestSpawnTimestamp;
		}

		if ( NumAISpawnsQueued >= OriginalSpawnManager.WaveTotalAI && 0 > FinalSpawnTimestamp )
		{
			FinalSpawnTimestamp = LatestSpawnTimestamp;
		}
	}

	OriginalSpawnManager.CohortZedsSpawned = 0;
	OriginalSpawnManager.CohortSquadsSpawned = 0;
	OriginalSpawnManager.CohortVolumeIndex = 0;
}

function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
	OriginalSpawnManager.SetupNextWave(NextWaveIndex,TimeToNextWaveBuffer);
	WaveTotalAI = OriginalSpawnManager.WaveTotalAI;
	
	WaveSetupTimestamp = Outer.WorldInfo.RealTimeSeconds;
	FirstSpawnTimestamp = -1.f;
	FinalSpawnTimestamp = -1.f;
	LatestSpawnTimestamp = -1.f;
	WaveEndTimestamp = -1.f;
	SpawnEventsThisWave = 0;
}

function bool IsFinishedSpawning()
{
	return OriginalSpawnManager.IsFinishedSpawning();
}

function int SpawnSquad( out array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
	return OriginalSpawnManager.SpawnSquad(AIToSpawn, bSkipHumanZedSpawning);
}

function SummonBossMinions( array<KFAISpawnSquad> NewMinionSquad, int NewMaxBossMinions, optional bool bUseLivingPlayerScale = true )
{
	OriginalSpawnManager.SummonBossMinions(NewMinionSquad, NewMaxBossMinions, bUseLivingPlayerScale);
}

function StopSummoningBossMinions()
{
	OriginalSpawnManager.StopSummoningBossMinions();
}

function int GetAIAliveCount()
{
    return OriginalSpawnManager.GetAIAliveCount();
}

defaultproperties
{
}

