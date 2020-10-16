# platform :ios, '9.0'

# RxSwift
def rxSwift
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources', '~> 4.0'
end

target 'Test' do
  use_frameworks!
  inhibit_all_warnings!
  
  target 'TestTests' do
    inherit! :search_paths
    rxSwift
  end
  
  target 'TestUITests' do
  end
  
end
