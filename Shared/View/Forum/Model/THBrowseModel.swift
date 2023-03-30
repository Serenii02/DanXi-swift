import SwiftUI

@MainActor
class THBrowseModel: ObservableObject {
    
    // MARK: - Hole Loading
    
    @Published var holes: [THHole] = []
    @Published var loading = false
    @Published var loadingError: Error?
    
    private func insertHoles(_ holes: [THHole]) {
        let currentIds = self.holes.map(\.id)
        let insertedHoles = holes.filter { !currentIds.contains($0.id) }
        withAnimation {
            self.holes.append(contentsOf: insertedHoles)
        }
    }
    
    func loadMoreHoles() async {
        loading = true
        defer { loading = false }
        
        // set start time
        var startTime: String? = nil
        if !holes.isEmpty {
            startTime = holes.last?.updateTime.ISO8601Format() // TODO: apply sort options
        } else if let baseDate = baseDate {
            startTime = baseDate.ISO8601Format()
        }
        
        // fetch holes
        do {
            let newHoles = try await THRequests.loadHoles(startTime: startTime, divisionId: division.id)
            insertHoles(newHoles)
        } catch {
            loadingError = error
        }
    }
    
    func refresh() async {
        do {
            let divisions = try await THRequests.loadDivisions()
            DXModel.shared.divisions = divisions
            if let currentDivision = divisions.filter({ $0.id == self.division.id }).first {
                self.division = currentDivision
            }
            self.holes = []
            await loadMoreHoles()
        } catch {
            loadingError = error
        }
    }
    
    // MARK: - Division
    
    @Published var division: THDivision = DXModel.shared.divisions.first! {
        didSet {
            self.holes = []
            Task {
                await loadMoreHoles()
            }
        }
    }
    
    // MARK: - Hole Sort & Filter
    
    enum SortOption {
        case replyTime
        case createTime
    }
    
    @Published var sortOption = SortOption.createTime {
        didSet {
            self.holes = []
            Task {
                await loadMoreHoles()
            }
        }
    }
    @Published var baseDate: Date? {
        didSet {
            self.holes = []
            Task {
                await loadMoreHoles()
            }
        }
    }
    
    var filteredHoles: [THHole] {
        holes.filter { hole in
            let settings = THSettings.shared
            
            // filter for blocked tags
            let tagsSet = Set(hole.tags.map(\.name))
            let blockedSet = Set(settings.blockedTags)
            if !blockedSet.intersection(tagsSet).isEmpty {
                return false
            }
            
            // filter pinned hole
            if division.pinned.map(\.id).contains(hole.id) {
                return false
            }
            
            // filter NSFW tag
            if hole.nsfw && settings.sensitiveContent == .hide {
                return false
            }
            
            // filter locally blocked holes
            if settings.blockedHoles.contains(hole.id) {
                return false
            }
            
            return true
        }
    }
}
