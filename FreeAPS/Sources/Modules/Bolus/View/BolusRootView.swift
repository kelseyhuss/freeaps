import SwiftUI
import Swinject

extension Bolus {
    struct RootView: BaseView {
        let resolver: Resolver
        let waitForSuggestion: Bool
        @StateObject var state = StateModel()
        @State private var isAddInsulinAlertPresented = false

        private var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            return formatter
        }

        var body: some View {
            Form {
                // Section(header: Text("Recommendation")) {
                Section {
                    if state.waitForSuggestion {
                        HStack {
                            Text("Wait please").foregroundColor(.secondary)
                            Spacer()
                            ActivityIndicator(isAnimating: .constant(true), style: .medium) // fix iOS 15 bug
                        }
                    } else {
                        HStack {
                            Text("Insulin required").foregroundColor(.secondary)
                            Spacer()
                            Text(
                                formatter
                                    .string(from: state.insulinRequired as NSNumber)! +
                                    NSLocalizedString(" U", comment: "Insulin unit")
                            ).foregroundColor(.secondary)
                        }.contentShape(Rectangle())
                            .onTapGesture {
                                state.amount = state.insulinRequired
                            }
                        HStack {
                            Text("Insulin recommended")
                            Spacer()
                            Text(
                                formatter
                                    .string(from: state.insulinRecommended as NSNumber)! +
                                    NSLocalizedString(" U", comment: "Insulin unit")
                            ).foregroundColor(.secondary)
                        }.contentShape(Rectangle())
                            .onTapGesture {
                                state.amount = state.insulinRecommended
                            }
                        // }
                        // }

                        // if !state.waitForSuggestion {
                        //    Section(header: Text("Bolus")) {

                        //   VStack {
                        HStack {
                            Text("Amount")
                            Spacer()
                            DecimalTextField(
                                "0",
                                value: $state.amount,
                                formatter: formatter,
                                autofocus: true,
                                cleanInput: true
                            )
                            Text("U").foregroundColor(.secondary)
                        }
                        HStack {
                            if state.amount > 0 {
                                Button { state.add() }
                                label: { Text("Enact bolus") }
                                    .disabled(state.amount > state.inslinRequired)
                            } else {
                                Button { state.hideModal() } // happens to handle amount = 0 fine
                                label: { Text("Skip bolus") }
                            }
                            Spacer()
                        }
                        //      }
                        //   }
                    }
                    /*
                     Section {
                         if waitForSuggestion {
                             Button { state.showModal(for: nil) }
                             label: { Text("Continue without bolus") }
                         } else {
                             Button { isAddInsulinAlertPresented = true }
                             label: { Text("Add insulin without actually bolusing") }
                                 .disabled(state.amount <= 0)
                         }
                     }
                     */
                }
            }
            .alert(isPresented: $isAddInsulinAlertPresented) {
                let amount = formatter
                    .string(from: state.amount as NSNumber)! + NSLocalizedString(" U", comment: "Insulin unit")
                return Alert(
                    title: Text("Are you sure?"),
                    message: Text("Add \(amount) without bolusing"),
                    primaryButton: .destructive(
                        Text("Add"),
                        action: { state.addWithoutBolus() }
                    ),
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                configureView {
                    state.waitForSuggestionInitial = waitForSuggestion
                    state.waitForSuggestion = waitForSuggestion
                }
            }
            .navigationTitle("Enact Bolus")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarItems(leading: Button("Close", action: state.hideModal))
        }
    }
}

// fix iOS 15 bug
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct Previews_BolusRootView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
