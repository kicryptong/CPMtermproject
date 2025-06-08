//
//  FirstView.swift
//  NewWeather
//
//  Created by 김형관 on 2023/04/25.
//

import SwiftUI
import CoreLocationUI

struct FirstView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack {

                Text("Weather")
                    .font(.largeTitle)
                    .padding()
            .multilineTextAlignment(.center)
            
            LocationButton(.shareCurrentLocation) {
                locationManager.requestLocation()
            }
            .cornerRadius(10)
            .foregroundColor(.white)
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView()
    }
}

