//
//  ServiceView.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 26.04.26.
//

import SwiftUI

struct ServiceView: View {
    
    @StateObject var viewModel: ServiceViewModel = ServiceViewModel()
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack() {
                    NavigationBar()
                    ServiceHeaderView()
                    
                    VStack(alignment: .leading, spacing: 33) {
                        ForEach(viewModel.sections) { section in
                            
                            HStack(spacing: 16) {
                                Image(section.type.iconName)
                                Text("Section")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.white)
                                
                            }
                            .padding(.horizontal, 12)
                            
                            ForEach(section.services) { service in
                                ServiceItemView(service: service)
                            }
                        }
                    }
                    .padding(.top, 32)
                }
                
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    ServiceView()
}
