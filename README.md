# Is This Red?
✨ Accepted for WWDC26 Swift Student Challenge

<img width="1280" height="706" alt="image" src="https://github.com/user-attachments/assets/2ac27151-2e03-4a09-9d7f-57c2bdd8e672" />



[블로그 바로가기](https://oieunxe.tistory.com/entry/WWDC26-Swift-Student-Challenge-Winner%EC%97%90-%EC%84%A0%EC%A0%95%EB%90%98%EB%8B%A4?category=1347663)

## About

**Is This Red?**는 색이 모두에게 같은 방식으로 보이지 않는다는 점을 직접 체험할 수 있도록 만든 SwiftUI 앱입니다. 사용자는 처음에 여러 색을 보며 "이것이 빨간색인가?"를 선택하고, 이어서 자신이 본 색과 다른 사람이 보는 색이 다를 수 있다는 메시지를 마주합니다.

앱은 두 가지 체험을 제공합니다.

- **See Through Their Eyes**: PencilKit 캔버스에 자유롭게 그림을 그리고, 그 그림이 다양한 색각 조건에서 어떻게 보이는지 원본과 나란히 비교합니다.
- **Draw As Them**: Protanopia, Deuteranopia, Tritanopia, Achromatopsia 중 하나를 선택해 제한된 색각 시뮬레이션 상태에서 미션 그림을 그린 뒤, 실제 색상과 비교하며 색에만 의존한 표현의 한계를 체험합니다.

## Key Features

- SwiftUI 기반의 온보딩과 체험 흐름
- PencilKit을 활용한 드로잉 캔버스
- 펜, 연필, 브러시, 지우개, 라쏘, 색상 팔레트, 선 굵기 조절
- Core Image color matrix를 이용한 색각 시뮬레이션
- Protanopia, Deuteranopia, Tritanopia, Achromatopsia 모드 지원
- 원본 이미지와 시뮬레이션 이미지를 비교하는 리빌 기능

## Tech Stack

- Swift
- SwiftUI
- PencilKit
- Core Image
