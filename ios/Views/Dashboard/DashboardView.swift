import SwiftUI
import Charts

struct DashboardView: View {
    // MARK: - Environment and State Properties
    @EnvironmentObject var filters: FilterViewModel
    @EnvironmentObject var navigation: NavigationViewModel
    @EnvironmentObject var settings: SettingsViewModel
    
    @StateObject private var viewModel = DashboardViewModel()
    
    @State private var showSettings = false
    @State private var selectedAgencyResult: AgencySpendingResult?
    
    // State to control the presentation of the "About" sheet
    @State private var isAboutSheetPresented = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    totalSpendingCard
                    topAgenciesCard
                    topPSCsCard
                    topRecipientsCard
                    topCovidRecipientsCard
                    yourSliceCard

                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAboutSheetPresented = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .principal) { FiscalYearSelectorView() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape.fill") }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $isAboutSheetPresented) {
                AboutView()
            }
            .onChange(of: selectedAgencyResult) { _, newResult in
                if let result = newResult {
                    navigation.navigateToAgency(result)
                }
            }
            .task(id: "\(filters.selectedYear)-\(filters.selectedQuarter)") {
                await viewModel.fetchDashboardData(for: filters.selectedYear, quarter: filters.selectedQuarter)
            }
            .onAppear {
                selectedAgencyResult = nil
            }
        }
    }
    
    // MARK: - Private Card Views
    
    private var totalSpendingCard: some View {
        VStack(alignment: .leading) {
            Text("Total Government Spending")
                .font(.title2).bold() // foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.totalSpending, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.title2)
                    .foregroundColor(.green)
                    .foregroundColor(.primary)
                Text("(\(viewModel.totalSpending, format: .currency(code: "USD").notation(.compactName)))")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var topAgenciesCard: some View {
        VStack(alignment: .leading) {
            Text("Top Spending Agencies").font(.title2).bold()
            
            switch viewModel.viewState {
            case .loading:
                HStack {
                    Spacer()
                    ProgressView("Loading Data...")
                    Spacer()
                }
                .frame(height: 300)
                
            case .success:
                Chart(viewModel.topAgencies) { agency in
                    BarMark(
                        x: .value("Spending", agency.amount),
                        y: .value("Agency", agency.shortName)
                    )
                    .foregroundStyle(agency.color)
                    .annotation(position: .trailing) {
                        Text(agency.amount, format: .currency(code: "USD").notation(.compactName))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic) { value in
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick()
                        AxisValueLabel() {
                            if let agencyShortName = value.as(String.self) {
                                Text(agencyShortName)
                                    .font(.body)
                                    .lineLimit(1, reservesSpace: true)
                                    .frame(maxWidth: 280, alignment: .trailing)
                            }
                        }
                    }
                }
                .chartXAxis(.hidden)
                .frame(height: 380)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                SpatialTapGesture()
                                    .onEnded { value in
                                        selectedAgencyResult = findTappedAgency(location: value.location, proxy: proxy, geometry: geo)
                                    }
                            )
                    }
                }
                
            case .error(let message):
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        Text("Could Not Load Data")
                            .font(.headline)
                        Text(message)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .frame(height: 300)
            }
        }
    }
    
    @ViewBuilder
    private var topCovidRecipientsCard: some View {
        VStack(alignment: .leading) {
            Text("Top COVID-19 Recipients").font(.title2).bold()
            
            switch viewModel.viewState {
            case .loading:
                EmptyView()
            case .success:
                if viewModel.topCovidRecipients.isEmpty {
                    Text("No COVID-19 recipient data available for this period.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(height: 300)
                } else {
                    Chart(viewModel.topCovidRecipients) { recipient in
                        BarMark(
                            x: .value("Amount", recipient.amount),
                            y: .value("Recipient", recipient.name)
                        )
                        .foregroundStyle(recipient.color)
                        .annotation(position: .trailing) {
                            Text(recipient.amount, format: .currency(code: "USD").notation(.compactName))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine().foregroundStyle(.clear)
                            AxisTick().foregroundStyle(.clear)
                            AxisValueLabel {
                                if let recipientName = value.as(String.self) {
                                    Text(recipientName)
                                        .font(.caption)
                                        .lineLimit(1, reservesSpace: true)
                                        .frame(maxWidth: 280, alignment: .trailing)
                                }
                            }
                        }
                    }
                    .chartXAxis(.hidden)
                    .frame(height: 400)
                }
            case .error:
                EmptyView()
            }
        }
    }
    
    private var topPSCsCard: some View {
        VStack(alignment: .leading) {
            Text("Top Spending Categories").font(.title2).bold()
            
            switch viewModel.viewState {
            case .loading:
                EmptyView()
            
            case .success:
                 Chart(viewModel.topPSCCategories) { category in
                    SectorMark(
                        angle: .value("Spending", category.amount),
                        innerRadius: .ratio(0.5)
                    )
                    .foregroundStyle(category.color)
                    .annotation(position: .overlay) {
                        Text(category.amount, format: .currency(code: "USD").notation(.compactName))
                            .font(.body)
                            .bold()
                            .foregroundColor(.black)
                    }
                }
                 .chartForegroundStyleScale(
                    domain: viewModel.topPSCCategories.map { $0.name },
                    range: viewModel.topPSCCategories.map { $0.color }
                )
                .chartLegend(position: .bottom, alignment: .center, spacing: 10)
                .frame(height: 480)
            
            case .error:
                EmptyView()
            }
        }
    }
    
    private var topRecipientsCard: some View {
        VStack(alignment: .leading) {
            Text("Top Organizational Recipients").font(.title2).bold()
            
            switch viewModel.viewState {
            case .loading:
                EmptyView()
            case .success:
                Chart(viewModel.topRecipients) { recipient in
                    BarMark(x: .value("Amount", recipient.amount),
                            y: .value("Recipient", recipient.name))
                        .foregroundStyle(recipient.color)
                        .annotation(position: .trailing) {
                            Text(recipient.amount, format: .currency(code: "USD").notation(.compactName))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                }
                .chartYAxis {
                     AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick().foregroundStyle(.clear)
                        AxisValueLabel {
                            if let recipientName = value.as(String.self) {
                                Text(recipientName)
                                    .font(.caption)
                                    .lineLimit(1, reservesSpace: true)
                                    .frame(maxWidth: 280, alignment: .trailing)
                            }
                        }
                    }
                }
                .chartXAxis(.hidden)
                .frame(height: 380)

                if viewModel.amountForMultipleRecipients > 0 {
                    Divider().padding(.vertical, 8)
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spending to Individuals")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(viewModel.amountForMultipleRecipients, format: .currency(code: "USD").notation(.compactName))
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Includes benefits like Social Security, Medicare, etc.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

            case .error:
                EmptyView()
            }
        }
    }
    
    private var yourSliceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Slice of the Pie")
                .font(.title2).bold()

            VStack {
                if settings.taxContribution > 0 {
                    ZStack {
                        Circle()
                            .stroke(Color.green.opacity(0.3), lineWidth: 25)
                        Circle()
                            .trim(from: 0, to: 0.005)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text(settings.calculateContribution(for: viewModel.totalSpending), format: .currency(code: "USD").precision(.fractionLength(2)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 180, height: 180)
                    .padding(.vertical, 10)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "percent.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                            .padding(.bottom, 4)
                        Text("Personalize This View")
                            .font(.headline)
                            .multilineTextAlignment(.center)

                        Text("Enter your annual federal tax in Settings to see your estimated contribution.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            showSettings = true
                        } label: {
                            Text("Go to Settings")
                                .fontWeight(.semibold)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 20)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func findTappedAgency(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> AgencySpendingResult? {
        guard let plotFrame = proxy.plotFrame else { return nil }
        let relativePosition = CGPoint(x: location.x - geometry[plotFrame].origin.x, y: location.y - geometry[plotFrame].origin.y)
        guard let (agencyCode, _) = proxy.value(at: relativePosition, as: (String, Double).self) else { return nil }
        return viewModel.topAgencies.first { $0.shortName == agencyCode }
    }
}
