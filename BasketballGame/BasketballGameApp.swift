//
//  BasketballGameApp.swift
//  BasketballGame
//
//  Created by Beckett Dunlavy on 6/5/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Models
struct BasketballGameApp: Identifiable, Hashable {
    let id = UUID()
    let homeTeam: String
    let awayTeam: String
    let date: Date
    let time: String
    let venue: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let league: String
    let ticketPrice: String?
    let description: String
//    let FirstPrize: String?
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BasketballGameApp, rhs: BasketballGameApp) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

// MARK: - Main App
@main
struct BasketballGamesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var games: [BasketballGameApp] = []
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GameListView(games: filteredGames, searchText: $searchText)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Games")
                }
                .tag(0)
            
            MapView(games: games, userLocation: locationManager.location)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(1)
            TournamentView(tournaments: filteredTournaments, searchText: $searchText)
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Tournaments")
                }
                .tag(2)
        }
        .onAppear {
            locationManager.requestLocation()
            loadSampleGames()
        }
    }
    
    private var filteredGames: [BasketballGameApp] {
        if searchText.isEmpty {
            return games.sorted { $0.date < $1.date }
        } else {
            return games.filter { game in
                game.homeTeam.localizedCaseInsensitiveContains(searchText) ||
                game.awayTeam.localizedCaseInsensitiveContains(searchText) ||
                game.venue.localizedCaseInsensitiveContains(searchText) ||
                game.league.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.date < $1.date }
        }
    }
    
    private var filteredTournaments: [BasketballGameApp] {
        if searchText.isEmpty {
            return games.sorted { $0.date < $1.date }
        } else {
            return games.filter { game in
                game.homeTeam.localizedCaseInsensitiveContains(searchText) ||
                game.awayTeam.localizedCaseInsensitiveContains(searchText) ||
                game.venue.localizedCaseInsensitiveContains(searchText) ||
                game.league.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.date < $1.date }
        }
    }
    
    private func loadSampleGames() {
        let calendar = Calendar.current
        let today = Date()
        
        games = [
            BasketballGameApp(
                homeTeam: "Albuquerque Thunder",
                awayTeam: "Santa Fe Storm",
                date: calendar.date(byAdding: .day, value: 2, to: today) ?? today,
                time: "7:00 PM",
                venue: "Tingley Coliseum",
                address: "300 San Pedro Dr NE, Albuquerque, NM",
                coordinate: CLLocationCoordinate2D(latitude: 35.0844, longitude: -106.6504),
                league: "Southwest Basketball League",
                ticketPrice: "$15-45",
                description: "Rivalry game between two top teams in the Southwest Basketball League."
            ),
            BasketballGameApp(
                homeTeam: "Los Alamos Lakers",
                awayTeam: "Taos Tigers",
                date: calendar.date(byAdding: .day, value: 5, to: today) ?? today,
                time: "6:30 PM",
                venue: "Los Alamos High School Gym",
                address: "1300 Diamond Dr, Los Alamos, NM",
                coordinate: CLLocationCoordinate2D(latitude: 35.8800, longitude: -106.2989),
                league: "High School Division",
                ticketPrice: "$8-12",
                description: "High school championship semifinal game."
            ),
            BasketballGameApp(
                homeTeam: "Rio Rancho Rockets",
                awayTeam: "Farmington Flyers",
                date: calendar.date(byAdding: .day, value: 7, to: today) ?? today,
                time: "8:00 PM",
                venue: "Rio Rancho Events Center",
                address: "3001 Civic Center Cir NE, Rio Rancho, NM",
                coordinate: CLLocationCoordinate2D(latitude: 35.2327, longitude: -106.6630),
                league: "New Mexico Pro League",
                ticketPrice: "$20-60",
                description: "Professional league game featuring rising stars."
            ),
            BasketballGameApp(
                homeTeam: "UNM Lobos JV",
                awayTeam: "NMSU Aggies JV",
                date: calendar.date(byAdding: .day, value: 10, to: today) ?? today,
                time: "5:00 PM",
                venue: "Johnson Center",
                address: "1 University of New Mexico, Albuquerque, NM",
                coordinate: CLLocationCoordinate2D(latitude: 35.0844, longitude: -106.6218),
                league: "College Junior Varsity",
                ticketPrice: "Free",
                description: "Junior varsity matchup between state university rivals."
            ),
            BasketballGameApp(
                homeTeam: "Roswell Aliens",
                awayTeam: "Carlsbad Cavemen",
                date: calendar.date(byAdding: .day, value: 12, to: today) ?? today,
                time: "7:30 PM",
                venue: "Roswell Recreation Center",
                address: "912 N Main St, Roswell, NM",
                coordinate: CLLocationCoordinate2D(latitude: 33.3943, longitude: -104.5230),
                league: "Southeast New Mexico League",
                ticketPrice: "$10-25",
                description: "Regional league game with playoff implications."
            ),
            BasketballGameApp(
                homeTeam: "Las Cruces Heat",
                awayTeam: "Silver City Miners",
                date: calendar.date(byAdding: .day, value: 14, to: today) ?? today,
                time: "6:00 PM",
                venue: "Las Cruces Convention Center",
                address: "680 E University Ave, Las Cruces, NM",
                coordinate: CLLocationCoordinate2D(latitude: 32.3199, longitude: -106.7637),
                league: "Southwest Basketball League",
                ticketPrice: "$12-35",
                description: "Southern division showdown between conference leaders."
            )
        ]
    }
}

// MARK: - Game List View
struct GameListView: View {
    let games: [BasketballGameApp]
    @Binding var searchText: String


    
    var body: some View {
        NavigationView {
            VStack {
                HStack{
                    SearchBar(text: $searchText, games: games)
                }
                List(games) { game in
                    NavigationLink(destination: GameDetailView(game: game)) {
                        GameRowView(game: game)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Local Basketball Games")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - tournament view
struct TournamentView: View {
    let tournaments: [BasketballGameApp]
    @Binding var searchText: String
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, games: tournaments)
                
                List(tournaments) { game in
                    NavigationLink(destination: GameDetailView(game: game)) {
                        GameRowView(game: game)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Local Basketball Tournaments")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let games: [BasketballGameApp]
    @State var showingMapView: Bool = false
   
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search games, teams, venues...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                            showingMapView = true
                        }) {
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingMapView) {
            MapViewSheet(games: games)
        }
    }
}

// MARK: - map view sheet
struct MapViewSheet: View {
    var games: [BasketballGameApp]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    
    
    var body: some View {
        VStack {
            HStack{
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }.padding(EdgeInsets(top: 10, leading: 8, bottom: 0, trailing: 8))
            }
            
            MapView(games: games, userLocation: locationManager.location)
        }
        }
    
}

// MARK: - Game Row View
struct GameRowView: View {
    let game: BasketballGameApp
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(game.awayTeam) @ \(game.homeTeam)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(game.league)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(game.date, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(game.time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                
                Text(game.venue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let price = game.ticketPrice {
                    Text(price)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Game Detail View
struct GameDetailView: View {
    let game: BasketballGameApp
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack {
                            Text(game.awayTeam)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("Away")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("@")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        VStack {
                            Text(game.homeTeam)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("Home")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    Text(game.league)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Game Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Game Information")
                        .font(.headline)
                    
                    InfoRow(icon: "calendar", title: "Date", value: game.date.formatted(date: .abbreviated, time: .omitted))
                    InfoRow(icon: "clock", title: "Time", value: game.time)
                    InfoRow(icon: "location", title: "Venue", value: game.venue)
                    InfoRow(icon: "map", title: "Address", value: game.address)
                    
                    if let price = game.ticketPrice {
                        InfoRow(icon: "ticket", title: "Tickets", value: price)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Game")
                        .font(.headline)
                    
                    Text(game.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Map Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                    
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: game.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )), annotationItems: [game]) { game in
                        MapPin(coordinate: game.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Game Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Map View
struct MapView: View {
    let games: [BasketballGameApp]
    let userLocation: CLLocation?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.0844, longitude: -106.6504), // Albuquerque
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
    )
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: games) { game in
                MapAnnotation(coordinate: game.coordinate) {
                    NavigationLink(destination: GameDetailView(game: game)) {
                        VStack {
                            Image(systemName: "basketball.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(8)
                                .background(Color.orange)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            
                            Text(game.venue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white)
                                .cornerRadius(4)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .navigationTitle("Game Locations").font(.subheadline)
            .onAppear {
                if let userLoc = userLocation {
                    region.center = userLoc.coordinate
                }
            }
        }
    }
}
