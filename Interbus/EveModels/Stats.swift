import Foundation

struct CharacterStats: Codable {
    var activity: CharacterActivityStats?
    var combat: CharacterCombatStats?
    var industry: CharacterIndustryStats?
    var isk: CharacterIskStats?
    var inventory: CharacterInventoryStats?
    var market: CharacterMarketStats?
    var mining: CharacterMiningStats?
    var module: CharacterModuleStats?
    var orbital: CharacterOrbitalStats?
    var pve: CharacterPveStats?
    var social: CharacterSocialStats?
    var travel: CharacterTravelStats?
    var year: Int

    enum CodingKeys: String, CodingKey {
        case activity = "character"
        case combat
        case industry
        case isk
        case inventory
        case market
        case mining
        case module
        case orbital
        case pve
        case social
        case travel
        case year
    }
}

struct CharacterActivityStats: Codable {
    var daysOfActivity: Int64?
    var minutes: Int64?
    var sessionsStarted: Int64?
}

struct CharacterCombatStats: Codable {
    var capDrainedbyNpc: Int64?
    var capDrainedbyPc: Int64?
    var capDrainingPc: Int64?
    var criminalFlagSet: Int64?
    var damageFromNpCsAmount: Int64?
    var damageFromNpCsNumShots: Int64?
    var damageFromPlayersBombAmount: Int64?
    var damageFromPlayersBombNumShots: Int64?
    var damageFromPlayersCombatDroneAmount: Int64?
    var damageFromPlayersCombatDroneNumShots: Int64?
    var damageFromPlayersEnergyAmount: Int64?
    var damageFromPlayersEnergyNumShots: Int64?
    var damageFromPlayersFighterBomberAmount: Int64?
    var damageFromPlayersFighterBomberNumShots: Int64?
    var damageFromPlayersFighterDroneAmount: Int64?
    var damageFromPlayersFighterDroneNumShots: Int64?
    var damageFromPlayersHybridAmount: Int64?
    var damageFromPlayersHybridNumShots: Int64?
    var damageFromPlayersMissileAmount: Int64?
    var damageFromPlayersMissileNumShots: Int64?
    var damageFromPlayersProjectileAmount: Int64?
    var damageFromPlayersProjectileNumShots: Int64?
    var damageFromPlayersSmartBombAmount: Int64?
    var damageFromPlayersSmartBombNumShots: Int64?
    var damageFromPlayersSuperAmount: Int64?
    var damageFromPlayersSuperNumShots: Int64?
    var damageFromStructuresTotalAmount: Int64?
    var damageFromStructuresTotalNumShots: Int64?
    var damageToPlayersBombAmount: Int64?
    var damageToPlayersBombNumShots: Int64?
    var damageToPlayersCombatDroneAmount: Int64?
    var damageToPlayersCombatDroneNumShots: Int64?
    var damageToPlayersEnergyAmount: Int64?
    var damageToPlayersEnergyNumShots: Int64?
    var damageToPlayersFighterBomberAmount: Int64?
    var damageToPlayersFighterBomberNumShots: Int64?
    var damageToPlayersFighterDroneAmount: Int64?
    var damageToPlayersFighterDroneNumShots: Int64?
    var damageToPlayersHybridAmount: Int64?
    var damageToPlayersHybridNumShots: Int64?
    var damageToPlayersMissileAmount: Int64?
    var damageToPlayersMissileNumShots: Int64?
    var damageToPlayersProjectileAmount: Int64?
    var damageToPlayersProjectileNumShots: Int64?
    var damageToPlayersSmartBombAmount: Int64?
    var damageToPlayersSmartBombNumShots: Int64?
    var damageToPlayersSuperAmount: Int64?
    var damageToPlayersSuperNumShots: Int64?
    var damageToStructuresTotalAmount: Int64?
    var damageToStructuresTotalNumShots: Int64?
    var deathsHighSec: Int64?
    var deathsLowSec: Int64?
    var deathsNullSec: Int64?
    var deathsPodHighSec: Int64?
    var deathsPodLowSec: Int64?
    var deathsPodNullSec: Int64?
    var deathsPodWormhole: Int64?
    var deathsWormhole: Int64?
    var droneEngage: Int64?
    var dscans: Int64?
    var duelRequested: Int64?
    var engagementRegister: Int64?
    var killsAssists: Int64?
    var killsHighSec: Int64?
    var killsLowSec: Int64?
    var killsNullSec: Int64?
    var killsPodHighSec: Int64?
    var killsPodLowSec: Int64?
    var killsPodNullSec: Int64?
    var killsPodWormhole: Int64?
    var killsWormhole: Int64?
    var npcFlagSet: Int64?
    var probeScans: Int64?
    var pvpFlagSet: Int64?
    var repairArmorByRemoteAmount: Int64?
    var repairArmorRemoteAmount: Int64?
    var repairArmorSelfAmount: Int64?
    var repairCapacitorByRemoteAmount: Int64?
    var repairCapacitorRemoteAmount: Int64?
    var repairCapacitorSelfAmount: Int64?
    var repairHullByRemoteAmount: Int64?
    var repairHullRemoteAmount: Int64?
    var repairHullSelfAmount: Int64?
    var repairShieldByRemoteAmount: Int64?
    var repairShieldRemoteAmount: Int64?
    var repairShieldSelfAmount: Int64?
    var selfDestructs: Int64?
    var warpScramblePc: Int64?
    var warpScrambledbyNpc: Int64?
    var warpScrambledbyPc: Int64?
    var weaponFlagSet: Int64?
    var webifiedbyNpc: Int64?
    var webifiedbyPc: Int64?
    var webifyingPc: Int64?
}

struct CharacterIndustryStats: Codable {
    var hackingSuccesses: Int64?
    var jobsCancelled: Int64?
    var jobsCompletedCopyBlueprint: Int64?
    var jobsCompletedInvention: Int64?
    var jobsCompletedManufacture: Int64?
    var jobsCompletedManufactureAsteroid: Int64?
    var jobsCompletedManufactureAsteroidQuantity: Int64?
    var jobsCompletedManufactureCharge: Int64?
    var jobsCompletedManufactureChargeQuantity: Int64?
    var jobsCompletedManufactureCommodity: Int64?
    var jobsCompletedManufactureCommodityQuantity: Int64?
    var jobsCompletedManufactureDeployable: Int64?
    var jobsCompletedManufactureDeployableQuantity: Int64?
    var jobsCompletedManufactureDrone: Int64?
    var jobsCompletedManufactureDroneQuantity: Int64?
    var jobsCompletedManufactureImplant: Int64?
    var jobsCompletedManufactureImplantQuantity: Int64?
    var jobsCompletedManufactureModule: Int64?
    var jobsCompletedManufactureModuleQuantity: Int64?
    var jobsCompletedManufactureOther: Int64?
    var jobsCompletedManufactureOtherQuantity: Int64?
    var jobsCompletedManufactureShip: Int64?
    var jobsCompletedManufactureShipQuantity: Int64?
    var jobsCompletedManufactureStructure: Int64?
    var jobsCompletedManufactureStructureQuantity: Int64?
    var jobsCompletedManufactureSubsystem: Int64?
    var jobsCompletedManufactureSubsystemQuantity: Int64?
    var jobsCompletedMaterialProductivity: Int64?
    var jobsCompletedTimeProductivity: Int64?
    var jobsStartedCopyBlueprint: Int64?
    var jobsStartedInvention: Int64?
    var jobsStartedManufacture: Int64?
    var jobsStartedMaterialProductivity: Int64?
    var jobsStartedTimeProductivity: Int64?
    var reprocessItem: Int64?
    var reprocessItemQuantity: Int64?
}

struct CharacterInventoryStats: Codable {
    var abandonLootQuantity: Int64?
    var trashItemQuantity: Int64?
}

struct CharacterIskStats: Codable {
    var iskIn: Int64?
    var iskOut: Int64?

    enum CodingKeys: String, CodingKey {
        case iskIn = "in"
        case iskOut = "out"
    }
}

struct CharacterMarketStats: Codable {
    var acceptContractsCourier: Int64?
    var acceptContractsItemExchange: Int64?
    var buyOrdersPlaced: Int64?
    var cancelMarketOrder: Int64?
    var createContractsAuction: Int64?
    var createContractsCourier: Int64?
    var createContractsItemExchange: Int64?
    var deliverCourierContract: Int64?
    var iskGained: Int64?
    var iskSpent: Int64?
    var modifyMarketOrder: Int64?
    var searchContracts: Int64?
    var sellOrdersPlaced: Int64?
}

struct CharacterMiningStats: Codable {
    var droneMine: Int64?
    var oreArkonor: Int64?
    var oreBistot: Int64?
    var oreCrokite: Int64?
    var oreDarkOchre: Int64?
    var oreGneiss: Int64?
    var oreHarvestableCloud: Int64?
    var oreHedbergite: Int64?
    var oreHemorphite: Int64?
    var oreIce: Int64?
    var oreJaspet: Int64?
    var oreKernite: Int64?
    var oreMercoxit: Int64?
    var oreOmber: Int64?
    var orePlagioclase: Int64?
    var orePyroxeres: Int64?
    var oreScordite: Int64?
    var oreSpodumain: Int64?
    var oreVeldspar: Int64?
}

struct CharacterModuleStats: Codable {
    var activationsArmorHardener: Int64?
    var activationsArmorRepairUnit: Int64?
    var activationsArmorResistanceShiftHardener: Int64?
    var activationsAutomatedTargetingSystem: Int64?
    var activationsBastion: Int64?
    var activationsBombLauncher: Int64?
    var activationsCapacitorBooster: Int64?
    var activationsCargoScanner: Int64?
    var activationsCloakingDevice: Int64?
    var activationsCloneVatBay: Int64?
    var activationsCynosuralField: Int64?
    var activationsDamageControl: Int64?
    var activationsDataMiners: Int64?
    var activationsDroneControlUnit: Int64?
    var activationsDroneTrackingModules: Int64?
    var activationsEccm: Int64?
    var activationsEcm: Int64?
    var activationsEcmBurst: Int64?
    var activationsEnergyDestabilizer: Int64?
    var activationsEnergyVampire: Int64?
    var activationsEnergyWeapon: Int64?
    var activationsFestivalLauncher: Int64?
    var activationsFrequencyMiningLaser: Int64?
    var activationsFueledArmorRepairer: Int64?
    var activationsFueledShieldBooster: Int64?
    var activationsGangCoordinator: Int64?
    var activationsGasCloudHarvester: Int64?
    var activationsHullRepairUnit: Int64?
    var activationsHybridWeapon: Int64?
    var activationsIndustrialCore: Int64?
    var activationsInterdictionSphereLauncher: Int64?
    var activationsMicroJumpDrive: Int64?
    var activationsMiningLaser: Int64?
    var activationsMissileLauncher: Int64?
    var activationsPassiveTargetingSystem: Int64?
    var activationsProbeLauncher: Int64?
    var activationsProjectedEccm: Int64?
    var activationsProjectileWeapon: Int64?
    var activationsPropulsionModule: Int64?
    var activationsRemoteArmorRepairer: Int64?
    var activationsRemoteCapacitorTransmitter: Int64?
    var activationsRemoteEcmBurst: Int64?
    var activationsRemoteHullRepairer: Int64?
    var activationsRemoteSensorBooster: Int64?
    var activationsRemoteSensorDamper: Int64?
    var activationsRemoteShieldBooster: Int64?
    var activationsRemoteTrackingComputer: Int64?
    var activationsSalvager: Int64?
    var activationsSensorBooster: Int64?
    var activationsShieldBooster: Int64?
    var activationsShieldHardener: Int64?
    var activationsShipScanner: Int64?
    var activationsSiege: Int64?
    var activationsSmartBomb: Int64?
    var activationsStasisWeb: Int64?
    var activationsStripMiner: Int64?
    var activationsSuperWeapon: Int64?
    var activationsSurveyScanner: Int64?
    var activationsTargetBreaker: Int64?
    var activationsTargetPainter: Int64?
    var activationsTrackingComputer: Int64?
    var activationsTrackingDisruptor: Int64?
    var activationsTractorBeam: Int64?
    var activationsTriage: Int64?
    var activationsWarpDisruptFieldGenerator: Int64?
    var activationsWarpScrambler: Int64?
    var linkWeapons: Int64?
    var overload: Int64?
    var repairs: Int64?
}

struct CharacterOrbitalStats: Codable {
    var strikeCharactersKilled: Int64?
    var strikeDamageToPlayersArmorAmount: Int64?
    var strikeDamageToPlayersShieldAmount: Int64?
}

struct CharacterPveStats: Codable {
    var dungeonsCompletedAgent: Int64?
    var dungeonsCompletedDistribution: Int64?
    var missionsSucceeded: Int64?
    var missionsSucceededEpicArc: Int64?
}

struct CharacterSocialStats: Codable {
    var addContactBad: Int64?
    var addContactGood: Int64?
    var addContactHigh: Int64?
    var addContactHorrible: Int64?
    var addContactNeutral: Int64?
    var addNote: Int64?
    var addedAsContactBad: Int64?
    var addedAsContactGood: Int64?
    var addedAsContactHigh: Int64?
    var addedAsContactHorrible: Int64?
    var addedAsContactNeutral: Int64?
    var calendarEventCreated: Int64?
    var chatMessagesAlliance: Int64?
    var chatMessagesConstellation: Int64?
    var chatMessagesCorporation: Int64?
    var chatMessagesFleet: Int64?
    var chatMessagesRegion: Int64?
    var chatMessagesSolarsystem: Int64?
    var chatMessagesWarfaction: Int64?
    var chatTotalMessageLength: Int64?
    var directTrades: Int64?
    var fleetBroadcasts: Int64?
    var fleetJoins: Int64?
    var mailsReceived: Int64?
    var mailsSent: Int64?
}

struct CharacterTravelStats: Codable {
    var accelerationGateActivations: Int64?
    var alignTo: Int64?
    var distanceWarpedHighSec: Int64?
    var distanceWarpedLowSec: Int64?
    var distanceWarpedNullSec: Int64?
    var distanceWarpedWormhole: Int64?
    var docksHighSec: Int64?
    var docksLowSec: Int64?
    var docksNullSec: Int64?
    var jumpsStargateHighSec: Int64?
    var jumpsStargateLowSec: Int64?
    var jumpsStargateNullSec: Int64?
    var jumpsWormhole: Int64?
    var warpsHighSec: Int64?
    var warpsLowSec: Int64?
    var warpsNullSec: Int64?
    var warpsToBookmark: Int64?
    var warpsToCelestial: Int64?
    var warpsToFleetMember: Int64?
    var warpsToScanResult: Int64?
    var warpsWormhole: Int64?
}


enum StatsError: Error {
    case decodeError
}

class Stats {

    unowned var character: EveCharacter
    var stats: [CharacterStats] = []

    init(character: EveCharacter) {
        self.character = character
    }

    func fetchStats(completion: @escaping ([CharacterStats]?, StatsError?) -> ()) {
        let esi = ESIClient.sharedInstance
        esi.invoke(endPoint: "/v2/characters/\(character.id)/stats/", token: character.token) { response in
            if let data = response.rawResponse.data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    self.stats = (try decoder.decode([CharacterStats].self, from: data)).sorted {
                        $0.year < $1.year
                    }
                    completion(self.stats, nil)
                } catch let error {
                    completion(nil, .decodeError)
                    print(error)
                }
            }
        }
    }
}
