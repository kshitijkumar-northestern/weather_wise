//
//  AppStorageServices.swift
//  WeatherWise
//

import Foundation

final class CriteriaStore: CriteriaPersisting {
    private let key = "weatherwise.criteria"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadCriteria() -> WeatherCriteria {
        guard let data = defaults.data(forKey: key),
              var criteria = try? JSONDecoder().decode(WeatherCriteria.self, from: data) else {
            return .default
        }
        criteria.normalize()
        return criteria
    }

    func saveCriteria(_ criteria: WeatherCriteria) {
        var copy = criteria
        copy.normalize()
        guard let data = try? JSONEncoder().encode(copy) else { return }
        defaults.set(data, forKey: key)
    }
}

final class HistoryStore: HistoryPersisting {
    private let key = "weatherwise.history"
    private let defaults: UserDefaults
    private let maxRecords: Int

    init(defaults: UserDefaults = .standard, maxRecords: Int = 50) {
        self.defaults = defaults
        self.maxRecords = maxRecords
    }

    func loadHistory() -> [WeatherCheckRecord] {
        guard let data = defaults.data(forKey: key),
              let records = try? JSONDecoder().decode([WeatherCheckRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.timestamp > $1.timestamp }
    }

    func saveHistory(_ records: [WeatherCheckRecord]) {
        let trimmed = Array(records.sorted { $0.timestamp > $1.timestamp }.prefix(maxRecords))
        guard let data = try? JSONEncoder().encode(trimmed) else { return }
        defaults.set(data, forKey: key)
    }

    func append(_ record: WeatherCheckRecord) {
        var records = loadHistory()
        records.insert(record, at: 0)
        saveHistory(records)
    }
}
