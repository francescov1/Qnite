//
//  HorizontalContainerViewController.swift
//

import UIKit

//TODO: Think about the transition methods of the child view controllers.
//TODO: Make UI configurable. Make use of UIAppearance?

public struct HorizontalContainerCreator {
    
    static public func horizontalContainerWithViewControllers(_ viewControllers: [UIViewController]) -> HorizontalContainerViewController {
        
        let horizontalCtrlNib = UINib(
            nibName: "HorizontalContainerViewController",
            bundle: Bundle(for: HorizontalContainerViewController.self))
            .instantiate(withOwner: nil, options: nil)
        
        let horizontalCtrl = horizontalCtrlNib.first as! HorizontalContainerViewController
        horizontalCtrl.viewControllers = viewControllers
        
        return horizontalCtrl
    }
}

open class HorizontalContainerViewController: UIViewController, UIScrollViewDelegate  {
    
    var productPages: [ProductPage]?
    
    //MARK: Properties
    @IBOutlet open weak var indexBarScrollView: UIScrollView!
    @IBOutlet open weak var indexBarContainerView: UIView!
    @IBOutlet open weak var indexBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet open weak var indexIndicatorView: UIView!
    @IBOutlet open weak var indexIndicatorViewCenterXConstraint: NSLayoutConstraint!
    fileprivate var indexIndicatorViewWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var contentScrollView: UIScrollView!
    @IBOutlet open weak var contentContainerView: UIView!
    
    open var indexBarTextColor = UIColor.white {
        didSet { indexBarElements.forEach { label in label.textColor = indexBarTextColor } }
    }
    
    open var indexBarHighlightedTextColor = UIColor.darkGray {
        didSet { indexBarElements.forEach { label in label.highlightedTextColor = indexBarHighlightedTextColor } }
    }
    
    fileprivate var indexBarElements: [UILabel] = []
    
    //Decides whether the indexBar should scroll to follow the index indicator view.
    fileprivate var indexBarShouldTrackIndicatorView = true
    
    //Saves the current page before the trait collection changes
    fileprivate var pageBeforeTraitCollectionChange: Int = 0
    
    open var viewControllers: [UIViewController] = [] {
        willSet {
            removeContentView()
        }
        
        didSet {
            setupContentView()
            setupIndexBar()
            updateIndexIndicatorViewPosition(0)
        }
    }
    
    
    //MARK: Rotation related events
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        pageBeforeTraitCollectionChange = contentScrollView.currentPage()
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //Restore previous page.
        //A slight delay is required since the scroll view's frame size has not yet been updated to reflect the new trait collection.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.contentScrollView.scrollToPageAtIndex(self.pageBeforeTraitCollectionChange, animated: true)
            
            //Update the indicator view position manully in case no scroll was performed
            self.updateIndexIndicatorViewPosition(self.contentScrollView.horizontalPercentScrolled())
            self.scrollToIndexIndicatorView()
        })
    }
    
    //MARK: Setup
    
    fileprivate func setupIndexBar() {
        indexBarElements.forEach { element in element.removeFromSuperview() }
        indexBarElements = createIndexBarElements()
        indexBarContainerView.addViewsHorizontally(indexBarElements)
        
        NSLayoutConstraint.activate(
            indexBarElements.map { element -> NSLayoutConstraint in
                element.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: indexBarElementWidthMultiplier())
        })
        
        
        indexIndicatorViewWidthConstraint?.isActive = false
        indexIndicatorViewWidthConstraint = indexIndicatorView.widthAnchor.constraint(
            equalTo: view.widthAnchor, multiplier: indexBarElementWidthMultiplier())
        indexIndicatorViewWidthConstraint?.isActive = true
    }
    
    fileprivate func createIndexBarElements() -> [UILabel] {
        var indexBarElements: [UILabel] = []
        for i in 0..<viewControllers.count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = viewControllers[i].title
            label.textColor = indexBarTextColor
            label.highlightedTextColor = indexBarHighlightedTextColor
            indexBarElements.append(label)
        }
        return indexBarElements
    }
    
//    fileprivate func createIndexBarElements2(productPages: [ProductPage]) -> [UIImage] {
//        var indexBarElements: [UIImage] = []
//        for i in 0..<viewControllers.count {
//            let image = UIImage(named: "\((productPages[i].getLogoImageName()))")
//            indexBarElements.append(image!)
//        }
//        return indexBarElements
//    }
    
    fileprivate func indexBarElementWidth() -> CGFloat {
        return view.bounds.size.width * indexBarElementWidthMultiplier()
    }
    
    fileprivate func indexBarElementWidthMultiplier() -> CGFloat {
        let maxNumberOfElementsPerScreen = 2.5
        let numberOfElements = Double(viewControllers.count > 0 ? viewControllers.count : 1)
        let multiplier = numberOfElements > maxNumberOfElementsPerScreen ?
            CGFloat(1) / CGFloat(maxNumberOfElementsPerScreen) :
            CGFloat(1) / CGFloat(numberOfElements)
        return multiplier
    }

    
    fileprivate func setupContentView() {
        let vcViews = viewControllers.map { vc -> UIView in
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            return vc.view
        }
        
        contentContainerView.addViewsHorizontally(vcViews)
        
        NSLayoutConstraint.activate(
            vcViews.map { vcView -> NSLayoutConstraint in
                vcView.widthAnchor.constraint(equalTo: view.widthAnchor)
        })
        
        
        contentScrollView.setHorizontalContentOffsetWithinBounds(0)
    }
    
    fileprivate func removeContentView() {
        viewControllers.forEach { vc in
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
    }
    
    //MARK: UIScrollViewDelegate
    
    /**
     Navigates to the corresponding view controller of the index that was tapped
     */
    @IBAction func onIndexBarTapped(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: sender.view)
        let indexOfElementAtTouchPoint = Int(touchPoint.x / indexBarElementWidth())
        
        //Don't scroll the index bar while moving indicator view
        indexBarShouldTrackIndicatorView = false
        
        contentScrollView.scrollToPageAtIndex(indexOfElementAtTouchPoint, animated: true)
    }
    
    
    /**
     Updates the position of the 'indexIndicatorView' based on the scroll-percentage of the 'content scroll view'.
     */
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            updateIndexIndicatorViewPosition(contentScrollView.horizontalPercentScrolled())
        }
    }
    
    /**
     Updates the position of the 'indexIndicatorView' by 'xPercent'
     
     If the new position of the 'indexIndicatorView' is outside of the current page and tracking is set to true:
     - the content offset of the 'index bar' is updated accordingly.
     
     */
    fileprivate func updateIndexIndicatorViewPosition(_ percentageHorizontalOffset: CGFloat) {
        let indexIndicatorWidth = indexBarElementWidth()
        
        //Divide 'indexIndicatorWidth' by two since we're using the center of the line as x
        let newCenterX = (indexBarScrollView.contentSize.width - indexIndicatorWidth) * percentageHorizontalOffset + indexIndicatorWidth/2
        indexIndicatorViewCenterXConstraint.constant = newCenterX
        
        highlightIndexBarElementAtXPosition(newCenterX)
        
        if indexBarShouldTrackIndicatorView {
            trackIndicatorView()
        }
    }
    
    func getCurrentIndex(_ percentageHorizontalOffset: CGFloat)->Int {
        let indexIndicatorWidth = indexBarElementWidth()
        
        let newCenterX = (indexBarScrollView.contentSize.width - indexIndicatorWidth) * percentageHorizontalOffset + indexIndicatorWidth/2
        return Int(newCenterX)
        
    }
    
    
    fileprivate func trackIndicatorView() {
        let indicatorLeftX = indexIndicatorView.frame.origin.x
        let indicatorRightX = indicatorLeftX + indexIndicatorView.frame.width
        let frameLeftX = indexBarScrollView.contentOffset.x
        let frameRightX = frameLeftX + indexBarScrollView.frame.size.width
        
        let shouldScrollRight = indicatorRightX > frameRightX
        let shouldScrollLeft = indicatorLeftX < frameLeftX
        
        if shouldScrollRight {
            let newX = indexIndicatorView.frame.origin.x + indexIndicatorView.bounds.width - view.bounds.width
            indexBarScrollView.setHorizontalContentOffsetWithinBounds(newX)
        } else if shouldScrollLeft  {
            let newX = indexIndicatorView.frame.origin.x
            indexBarScrollView.setHorizontalContentOffsetWithinBounds(newX)
        }
    }
    
    /**
     Highlights the index bar element at position 'X'
     */
    fileprivate func highlightIndexBarElementAtXPosition(_ x: CGFloat) {
        let indexOfElementAtXPosition = Int(x / indexBarElementWidth())
        for (index, label) in indexBarElements.enumerated() {
            label.isHighlighted = index == indexOfElementAtXPosition
        }
    }
    
    
    /**
     Called when the user taps on an element in the index bar, which triggers the content view to scroll.
     After scrolling has occurred, scroll to make the 'index scroll view' visible.
     */
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            scrollToIndexIndicatorView()
            
            //Restore tracking of indicator view
            indexBarShouldTrackIndicatorView = true
        }
        
    }
    
    /**
     After scrolling the 'content scroll view', scroll to make the 'index scroll view' visible.
     Called when the user manually scrolls the content scroll view.
     */
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contentScrollView {
            scrollToIndexIndicatorView()
        }
    }
    
    func scrollToIndexIndicatorView() {
        let indexViewIsVisible = indexBarScrollView.bounds.contains(indexIndicatorView.frame)
        if indexViewIsVisible == false {
            indexBarScrollView.scrollRectToVisible(indexIndicatorView.frame, animated: true)
        }
    }
}
