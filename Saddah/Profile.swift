//
//  Profile.swift
//  Saddah
//
//  Created by lujin mohammed on 25/09/1446 AH.
//

import SwiftUI

struct Profile: View {
    
    let userName = "محمد العتيبي"
    let userPhone = "+966 500000000"
    let userEmail = "mohammed@email.com"
    let userAge = "18"
    let userWeight = "75 kg"
    let userHeight = "175 cm"
    let steps = "8,500"
    let calories = "2,200 kcal"
    let exerciseDuration = "45 min"
    let sleepDuration = "7h 30m"
    let fitnessAnalysis = """
    معدل نبضك طبيعي ومستقر. مستوى الأوكسجين جيد جداً.
    النشاط اليومي جيد، ولكن يمكنك زيادة المشي لتحقيق تحسينات أفضل في لياقتك.
    حاول تحسين سعة الأوكسجين القصوى عبر تمارين التنفس والتمارين الهوائية.
    حافظ على نومك المنتظم لتعزيز استشفاء العضلات وتحقيق أفضل أداء رياضي.
    """
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .trailing, spacing: 15) {
                    SectionTitle(title: "بيانات حسابك")
                    ProfileRow(icon: "person.circle.fill", title: "الاسم", value: userName)
                    ProfileRow(icon: "phone.circle.fill", title: "رقم الجوال", value: userPhone)
                    ProfileRow(icon: "envelope.circle.fill", title: "الإيميل", value: userEmail)
                }
                .profileSection()
                
                .padding(.top, 20)

                
                VStack(alignment: .trailing, spacing: 15) {
                    SectionTitle(title: "بياناتك")
                    ProfileRow(icon: "calendar.circle.fill", title: "العمر", value: userAge)
                    ProfileRow(icon: "scalemass.fill", title: "الوزن", value: userWeight)
                    ProfileRow(icon: "ruler.fill", title: "الطول", value: userHeight)
                    ProfileRow(icon: "figure.walk", title: "عدد الخطوات", value: steps)
                    ProfileRow(icon: "clock.fill", title: "مدة التمرين", value: exerciseDuration)
                    ProfileRow(icon: "flame.fill", title: "السعرات المحروقة", value: calories)
                    ProfileRow(icon: "moon.zzz.fill", title: "مدة النوم", value: sleepDuration)
                }
                .profileSection()




                
                VStack(alignment: .trailing, spacing: 10) {
                    SectionTitle(title: "تحليل الأداء الرياضي")

                    Text(fitnessAnalysis)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // ترجع للوراء
                            // تحتاج بيئة التنقل
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.backward")
                                Text("رجوع")
                            }
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("ملفي الشخصي")
                            .font(.largeTitle)
                            .bold()
                    }
                }
                .navigationBarBackButtonHidden(true)

}
        }

    }
}


struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(value)
                .foregroundColor(.secondary)

            Spacer()

            Text(title)
                .fontWeight(.bold)

            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}


struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

extension View {
    func profileSection() -> some View {
        self
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

#Preview {
    Profile()
        }
