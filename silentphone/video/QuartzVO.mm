/*
Created by Janis Narbuts
Copyright © 2004-2012 Tivi LTD,www.tiviphone.com. All rights reserved.
Copyright © 2012-2013, Silent Circle, LLC.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Any redistribution, use, or modification is done solely for personal 
      benefit and not for any commercial purpose or for monetary gain
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name Silent Circle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SILENT CIRCLE, LLC BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/



#include <memory.h>
#include <CoreGraphics/CGColorSpace.h>
#import <QuartzCore/CALayer.h>

#include <sys/time.h>

unsigned int getTickCount();

CGContextRef MyCreateBitmapContext (int pixelsWide,
                                    int pixelsHigh, int **data)
{
   CGContextRef    context = NULL;
   CGColorSpaceRef colorSpace;
   void *          bitmapData;
   int             bitmapByteCount;
   int             bitmapBytesPerRow;
   
   bitmapBytesPerRow   = (pixelsWide * 4);// 1
   bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
#if 0
   colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);// 2
#else
   colorSpace = CGColorSpaceCreateDeviceRGB();
#endif
   // if(*data)free(*data);
   bitmapData = malloc( pixelsWide*pixelsHigh*4 );// 3
   if (bitmapData == NULL)
   {
      fprintf (stderr, "Memory not allocated!");
      return NULL;
   }
   
   context = CGBitmapContextCreate (bitmapData,// 4
                                    pixelsWide,
                                    pixelsHigh,
                                    8,      // bits per component
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaNoneSkipLast);//kCGImageAlphaPremultipliedLast);//kCGImageAlphaPremultipliedLast);
   if (context== NULL)
   {
      free (bitmapData);// 5
      fprintf (stderr, "Context not created!");
      return NULL;
   }
   *data=(int*)bitmapData;
   CGColorSpaceRelease( colorSpace );// 6
   
   
   return context;// 7
}


#import "QuartzVO.h"

@implementation QuartzImageView;

- (void)awakeFromNib
{
   dstLayer2=nil;
   dstLayer=nil;
   [self allocx];
   
}
- (void)allocx
{
   self.opaque = YES;
   pVO=NULL;
   dstLayer=nil;;
   dstLayer2=nil;
   prevL=NULL;
   
   void g_setQWview(void *p);
   g_setQWview(self);
}
/*
 -(void)allocx{
 }
 */
-(void)dealloc
{
   dstLayer2=nil;
   dstLayer=nil;
   [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
   UITouch *aTouch1 = [touches anyObject];
   CGPoint touchLocation = [aTouch1 locationInView:self];
   if(!_touchDetector)_touchDetector=self.touchDetector;
   if(_touchDetector)[_touchDetector onTouch:self updown:-1 x:touchLocation.x y:touchLocation.y];   
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   UITouch *aTouch1 = [touches anyObject];
   CGPoint touchLocation = [aTouch1 locationInView:self];
   if(!_touchDetector)_touchDetector=self.touchDetector;
   if(_touchDetector)[_touchDetector onTouch:self updown:0 x:touchLocation.x y:touchLocation.y];   
   
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
   UITouch *aTouch1 = [touches anyObject];
   CGPoint touchLocation = [aTouch1 locationInView:self];
   if(!_touchDetector)_touchDetector=self.touchDetector;
   if(_touchDetector)[_touchDetector onTouch:self  updown:1 x:touchLocation.x y:touchLocation.y];   
   
}



-(void)add_l{
   
   if(!dstLayer) {
      // [dstLayer removeFromSuperlayer];
      dstLayer2= [CALayer layer];
      dstLayer = [CALayer layer];
      [dstLayer retain];
      [dstLayer2 retain];
      
   }
   vm[0].dstLayer=dstLayer;
   vm[1].dstLayer=dstLayer2;
   
   
   
   //  self.layer re
}
-(void)redraw_scr:(int)iClear draw:(int)draw{
   
   [self add_l];
   
   if([self isHidden] && dstLayer2 && dstLayer)return;
   
   static int iPrevFrame=-1;
   int iRel=0;
   
   CTAVideoMem *vmDraw=&vm[draw];
   
   if(pVO){
      int pf=pVO->getLastFrameID();
      if(iPrevFrame==pf && !iClear)return;
      if(iPrevFrame!=-1)iRel=1;
      iPrevFrame=pf;
   }
#if 1
   CALayer *myLayer=vmDraw->dstLayer;
  
   self.clearsContextBeforeDrawing = !!iClear;

   
   
   {
      int iRecPortrait=pVO && pVO->getH()*5>pVO->getW()*6;
      vmDraw->imageEmpty = CGBitmapContextCreateImage(vmDraw->drawCtx);
      CGImageRetain(vmDraw->imageEmpty);
      myLayer.shouldRasterize=NO;
      myLayer.contents = (id) vmDraw->imageEmpty;
      myLayer.contentsGravity=iRecPortrait?kCAGravityResizeAspectFill:kCAGravityResizeAspect;//kCAGravityResizeAspect;//
      myLayer.borderWidth = 0.0;
      myLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
   }
   if(prevL==NULL){
      [self.layer addSublayer:vmDraw->dstLayer];
   }
   else{
      if(iClear){
         [prevL  removeFromSuperlayer];
         prevL.contents=nil;
         myLayer.contents=nil;
      }
      else{
         if(prevL!=vmDraw->dstLayer){
           [self.layer replaceSublayer:prevL with:vmDraw->dstLayer];
            if(prevL.contents )[prevL.contents release];
            prevL.contents=nil;
         }
      }
   }
   prevL=myLayer;

   if(iClear){iPrevFrame=-1;prevL=NULL;}

   if(!iClear)[myLayer needsDisplay];
   
   CGImageRelease(vmDraw->imageEmpty);
   
#endif
   
}
-(void)clearImg{
   vm[0].clear();
   vm[1].clear();
 //  if(data)memset(data,255,iDataSize);
}
-(void)drawRect:(CGRect)rect
{

}

-(void *) getNextData{
   iPrevVM=!iPrevVM;
   return (void*)vm[iPrevVM].getData();
}
-(int)getDrawInto{return iPrevVM;}

@end
#if  1



void CTVideoOut::stop(){
   if(!iStarted)return;
   iStarted=0;
   usleep(50*1000);
   QuartzImageView *q=(QuartzImageView*)qiw;
   if(q){
      dispatch_async(dispatch_get_main_queue(), ^(void) {
         QuartzImageView *q=(QuartzImageView*)qiw;
         if(q){
            [q clearImg];
            [q redraw_scr:1 draw:0];
         }
      });
      // if(q) [q clearImg];
   }
}

int CTVideoOut::start(){
   if(iStarted)return 0;
   iStarted=1;
   QuartzImageView *q=(QuartzImageView*)qiw;
   iNeedsClear=1;
   if(q){ [q clearImg];q->pVO=this;}
   
   iStarted=2;
   
   
   
   uiPosTs=0;
   return 0;
}
void CTVideoOut::startDraw(){
   
   QuartzImageView *q=(QuartzImageView*)qiw;

   dataLocked=(int*)[q getNextData];
   
}


int CTVideoOut::getImgParams(int &iYuv, int &iBpp, int &stride, int &iIsBRG, void **p){
   QuartzImageView *q=(QuartzImageView*)qiw;
   
   if(!q)return -1;
   
   if(iStarted!=2 || !dataLocked)
      return -1;
   
   iYuv=0;iBpp=32;stride=w*4;iIsBRG=1;

   *p=dataLocked;
   return 0;
}


void CTVideoOut::setScanLine(int iLine, int iXOff, unsigned char *p, int iLen, int iBits){
   
   int i;
   QuartzImageView *q=(QuartzImageView*)qiw;
   if(iLine>h || !q || iXOff>w || iStarted!=2 ||w<1|| h<1 || w>2000 || h>1500)return;
   if(!dataLocked)return ;
   if(iBits==32){
      unsigned int *pix=(unsigned int *)dataLocked+iLine*w+iXOff;
      memcpy(pix,p,iLen);
   }
   else{
      unsigned int *pix=(unsigned int *)dataLocked+(iLine)*w+iXOff;
      for(i=0;i<iLen;i+=3){
         *pix=p[2]|((unsigned int)p[1]<<8)|((unsigned int)p[0]<<16);
         pix++;p+=3;
      }
   }
    
}
void CTAVideoMem::rel(){
   if(data)free(data);
   if(drawCtx)CGContextRelease(drawCtx);
   data=NULL;
   drawCtx=NULL;
}
   

void CTAVideoMem::setSize(int cx, int cy){
   if((w!=cx || h!=cy)){
      
      CGContextRef drawCtxP=drawCtx;
      int *dataP=data;
      drawCtx=MyCreateBitmapContext(cx,cy,&data);
  
      if(w>0 && h>0)usleep(40*1000);

      iDataSize=cx*cy*4;
      w=cx;h=cy;
      if(drawCtxP)CGContextRelease(drawCtxP);
      if(dataP)free(dataP);
      //buf=new unsigned int[(w+2)*(h+2)];
   }
   
}

void CTVideoOut::setOutputPictureSize(int cx, int cy){
   if(cx>2000)cx=2000;//TODO fix
   if(cy>1200)cy=1200;
   QuartzImageView *q=(QuartzImageView*)qiw;
   if(q && (w!=cx || h!=cy)){
      q->pVO=this;
      q->vm[0].setSize(cx,cy);
      q->vm[1].setSize(cx,cy);
      w=cx;h=cy;
   }
}

void CTVideoOut::setQWview(void *p){
   qiw=p;
   dispatch_async(dispatch_get_main_queue(), ^(void) {
      QuartzImageView *q=(QuartzImageView*)qiw;

      if(q &&  w>0 && h>0){
         q->vm[0].setSize(w,h);
         q->vm[1].setSize(w,h);
      }
      
   });
   QuartzImageView *q2=(QuartzImageView*)qiw;
   if(q2)q2->pVO=this;
}

void CTVideoOut::endDraw(){
   iLastFrameID++;
}

int CTVideoOut::drawFrame(){
   if(qiw && iStarted==2){
      int iDrawInto=[(QuartzImageView*)qiw getDrawInto];
      
      dispatch_async(dispatch_get_main_queue(), ^(void) {
         QuartzImageView *q=(QuartzImageView*)qiw;
         if(q)[q redraw_scr:0 draw:iDrawInto];
      });
   }
   return 0;
}

#endif

















#if 0


-(void)drawInContext:(CGContextRef)context
{
	CGRect imageRect;
	imageRect.origin = CGPointMake(8.0, 8.0);
	imageRect.size = CGSizeMake(64.0, 64.0);
	
	// Note: The images are actually drawn upside down because Quartz image drawing expects
	// the coordinate system to have the origin in the lower-left corner, but a UIView
	// puts the origin in the upper-left corner. For the sake of brevity (and because
	// it likely would go unnoticed for the image used) this is not addressed here.
	// For the demonstration of PDF drawing however, it is addressed, as it would definately
	// be noticed, and one method of addressing it is shown there.
   
	// Draw the image in the upper left corner (0,0) with size 64x64
   if(!pVO || !pVO->isStarted())return; 
   
   //kCMPixelFormat_444YpCbCr8
   
	CGRect imageRect2;
   static int iPrevFrame=-1;
	if(!pVO){
      imageRect2.origin = CGPointMake(8.0, 80.0);
      imageRect2.size = pVO?CGSizeMake(pVO->getW(), pVO->getH()):CGSizeMake(128.0, 128.0);
   }
   else{
      CGFloat fw=self.bounds.size.width;
      CGFloat fh=self.bounds.size.height;
      
      CGFloat iw=pVO->getW();
      CGFloat ih=pVO->getH();
      // a/b=c/d
      if(1){
         imageRect2.size = CGSizeMake(pVO->getW(), pVO->getH());
      }else if(fw*ih>iw*ih){
         imageRect2.size = CGSizeMake(fw, fw*ih/iw);
      }else{
         //test this
         imageRect2.size = CGSizeMake(fh*ih/iw, fh);
      }
      imageRect2.origin = CGPointMake(((fw-imageRect2.size.width)/2), (fh-imageRect2.size.height)/2 );  
   }
   /*
    //very fast drawing, need custom scaling
    if(data && pVO && pVO->getW()>240){
    char *p=(char*)CGBitmapContextGetData (context);
    int str=CGBitmapContextGetBytesPerRow(context);
    int h=pVO->getH();
    // char *pd=(char*)data;
    int w=pVO->getW();
    for(int i=0;i<h;i++){
    memcpy(p+(h-i-1)*str,data+i*w,min(str,w*4));
    }
    //memcpy(p,data,320*240*2);
    return;
    }
    */
   //	imageRect2.size = CGSizeMake(300, 400);
   if(pVO){
      int pf=pVO->getLastFrameID();
      if(iPrevFrame==pf)return;
      iPrevFrame=pf;
   }
   unsigned int startT=getTickCount();
   //TODO mutex
   imageEmpty = CGBitmapContextCreateImage(drawCtx);
   unsigned int cr=getTickCount()-startT;
   
   CGContextSetInterpolationQuality(context,kCGInterpolationNone);
   
   //CGContextDrawImage(context, self.bounds, imageEmpty);
   CGContextDrawImage(context, imageRect2, imageEmpty);
   CGImageRelease(imageEmpty);
 	//CGContextDrawImage(context, imageRect2, imageEmpty);
   
   unsigned int dr=getTickCount()-startT;
   
   CGContextSetRGBFillColor(context, .5, .5, .5, .8);
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextSelectFont(context, "Helvetica", 16.0, kCGEncodingMacRoman);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
   
   // CGContextSetFontSize(context, 12.0);
	CGContextSetTextDrawingMode(context, kCGTextFill);
   char sz[64];
   int l=sprintf(sz,"cr=%d,sp=%d,cr+dr=%d",cr,dr-cr,dr);
   CGContextShowTextAtPoint(context, 10.0, 30.0, sz, l);
   
   //  [self performSelector:@selector(redraw_scr) withObject:nil afterDelay:.03];
   
   
   return ;
	
}
#endif

