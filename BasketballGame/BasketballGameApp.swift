import SwiftUI
import MapKit
import CoreLocation

// MARK: - AuthViewModel: Manages authentication state with in-memory simulation
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserProfile: UserProfile? // Represents the logged-in user's profile
    @Published var authError: String?

    // Simulated in-memory user store (no persistence across app launches)
    private var simulatedUsers: [String: UserProfile] = [
        "user@example.com": UserProfile(id: UUID().uuidString, email: "user@example.com", username: "DemoUser")
    ]

    init() {
        // Initially, no one is authenticated.
        isAuthenticated = false
        currentUserProfile = nil
    }

    // MARK: - Simulated Email/Password Registration
    func register(email: String, password: String, username: String) {
        authError = nil // Clear previous errors

        // Basic validation
        if email.isEmpty || password.isEmpty || username.isEmpty {
            authError = "All fields are required."
            return
        }
        if simulatedUsers[email] != nil {
            authError = "Account with this email already exists."
            return
        }
        if password.count < 6 { // Simple password length check
            authError = "Password must be at least 6 characters long."
            return
        }

        // Simulate successful registration
        let newProfile = UserProfile(id: UUID().uuidString, email: email, username: username)
        simulatedUsers[email] = newProfile // Store in our simulated database
        currentUserProfile = newProfile
        isAuthenticated = true
        print("Successfully registered and logged in user: \(username)")
    }

    // MARK: - Simulated Email/Password Login
    func login(email: String, password: String) {
        authError = nil // Clear previous errors

        // Basic validation
        if email.isEmpty || password.isEmpty {
            authError = "Email and password are required."
            return
        }

        // Simulate login success based on a hardcoded user or newly registered user
        if let profile = simulatedUsers[email], password == "password" || email == profile.email { // Simple password check
            currentUserProfile = profile
            isAuthenticated = true
            print("Successfully logged in user: \(profile.username)")
        } else {
            authError = "Invalid email or password."
            print("Login failed for email: \(email)")
        }
    }

    // MARK: - Simulated Anonymous Login (Guest)
    func signInAnonymously() {
        authError = nil // Clear previous errors
        let guestProfile = UserProfile(id: UUID().uuidString, email: "guest@example.com", username: "Guest User")
        currentUserProfile = guestProfile
        isAuthenticated = true
        print("Successfully signed in as Guest.")
    }

    // MARK: - Simulated Sign Out
    func signOut() {
        authError = nil // Clear previous errors
        isAuthenticated = false
        currentUserProfile = nil
        print("User signed out.")
    }
}

// MARK: - UserProfile Struct (to hold data from our simulated store)
struct UserProfile: Identifiable, Codable {
    let id: String
    let email: String
    let username: String
}

// MARK: - AuthenticationView: Login, Register, or Guest Options
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var username = "" // For registration
    @State private var showingRegistration = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Image(systemName: "basketball.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                    .padding(.bottom, 20)

                Text("AllHoops")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)

                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    if showingRegistration {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    if let error = authViewModel.authError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        if showingRegistration {
                            authViewModel.register(email: email, password: password, username: username)
                        } else {
                            authViewModel.login(email: email, password: password)
                        }
                    }) {
                        Text(showingRegistration ? "Register" : "Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)

                    Button(action: {
                        showingRegistration.toggle()
                        // Clear fields when switching modes
                        email = ""
                        password = ""
                        username = ""
                        authViewModel.authError = nil // Clear error
                    }) {
                        Text(showingRegistration ? "Already have an account? Login" : "Don't have an account? Register")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                // Continue as Guest button
                Button(action: {
                    authViewModel.signInAnonymously()
                }) {
                    Text("Continue as Guest")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .underline()
                }
                .padding(.bottom, 20)

                Spacer()
            }
            .navigationTitle("") // Hide default navigation title
            .navigationBarHidden(true) // Hide navigation bar for full screen login
        }
    }
}

// MARK: - ProfileView (Example for Authenticated Users)
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)

                Text(authViewModel.currentUserProfile?.username ?? "Welcome!")
                    .font(.title)
                    .fontWeight(.bold)

                if let email = authViewModel.currentUserProfile?.email {
                    Text("Email: \(email)")
                        .font(.headline)
                } else { // Handle case where email might be missing or for guest
                    Text("User not found or is Guest")
                        .font(.headline)
                }

                // In a simulated environment, there's no Firebase UID, so we just show a generic ID
                Text("Simulated User ID: \(authViewModel.currentUserProfile?.id ?? "N/A")")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)

                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// MARK: - IMPORTANT: Your original BasketballGameApp struct was a model.
// Keeping its original name as requested, but ensuring it's not the @main App struct.
struct BasketballGameApp: Identifiable, Hashable { // This is your game model
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
    //    let FirstPrize: String? // Commented out as it was in original
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BasketballGameApp, rhs: BasketballGameApp) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Location Manager (from your original code)
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


// MARK: - Main App (Modified for Authentication Flow)
@main
struct BasketballGamesApp: App {
    @StateObject private var authViewModel = AuthViewModel() // Initialize AuthViewModel here

    var body: some Scene {
        WindowGroup {
            // This ContentView now handles both authentication and main app content
            ContentView()
                .environmentObject(authViewModel) // Make authViewModel available to ContentView and its subviews
        }
    }
}

// MARK: - ContentView (Original ContentView, now integrated with auth logic)
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Access AuthViewModel from environment

    // Your original @State variables and functions from your provided ContentView
    @State private var selectedTab = 0
    @State private var searchText = ""
    @StateObject private var locationManager = LocationManager()
    @State private var games: [BasketballGameApp] = [] // Using original model name

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // If authenticated, show the main app content (your TabView)
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

                    ProfileView() // Add a tab for the new ProfileView
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(3)
                }
                .onAppear {
                    locationManager.requestLocation()
                    loadSampleGames()
                }
            } else {
                // If not authenticated, show the authentication screen
                AuthenticationView()
            }
        }
    }
    
    // Your original filteredGames, filteredTournaments, and loadSampleGames()
    private var filteredGames: [BasketballGameApp] { // Using original model name
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
    
    private var filteredTournaments: [BasketballGameApp] { // Using original model name
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
            BasketballGameApp( // Using original model name
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
            BasketballGameApp( // Using original model name
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
            BasketballGameApp( // Using original model name
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
            BasketballGameApp( // Using original model name
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
            BasketballGameApp( // Using original model name
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
            BasketballGameApp( // Using original model name
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

// MARK: - Game List View (from your original code)
struct GameListView: View {
    let games: [BasketballGameApp] // Using original model name
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

// MARK: - Tournament View (from your original code)
struct TournamentView: View {
    let tournaments: [BasketballGameApp] // Using original model name
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

// MARK: - Search Bar (from your original code)
struct SearchBar: View {
    @Binding var text: String
    let games: [BasketballGameApp] // Using original model name
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

// MARK: - Map View Sheet (from your original code)
struct MapViewSheet: View {
    var games: [BasketballGameApp] // Using original model name
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            MapView(games: games, userLocation: locationManager.location)
        }
        
    }
}
    
    // MARK: - Game Row View (from your original code)
    struct GameRowView: View {
        let game: BasketballGameApp // Using original model name
        
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
    
    // MARK: - Game Detail View (from your original code)
    struct GameDetailView: View {
        let game: BasketballGameApp // Using original model name
        
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
    
    // MARK: - Info Row (from your original code)
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
    
    // MARK: - Map View (from your original code)
    struct MapView: View {
        let games: [BasketballGameApp] // Using original model name
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
