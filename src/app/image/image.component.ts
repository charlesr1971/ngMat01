import { Component, OnInit, OnDestroy, Input, Inject, Renderer2, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { Lightbox, LightboxEvent, LIGHTBOX_EVENT } from 'angular2-lightbox';
import { DOCUMENT } from '@angular/common';
import { CookieService } from 'ngx-cookie-service';
import { trigger, state, style, animate, transition } from '@angular/animations';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';
import { faFacebookSquare } from '@fortawesome/free-brands-svg-icons/faFacebookSquare';
import { faTwitterSquare } from '@fortawesome/free-brands-svg-icons/faTwitterSquare';
import { faTumblrSquare } from '@fortawesome/free-brands-svg-icons/faTumblrSquare';
import { faLinkedinIn } from '@fortawesome/free-brands-svg-icons/faLinkedinIn';

import { Image } from './../image/image.model';
import { HttpService } from '../services/http/http.service';
import { environment } from '../../environments/environment';

declare var ease, TweenMax, TimelineMax, Elastic: any;

@Component({
  selector: 'app-image',
  templateUrl: './image.component.html',
  styleUrls: ['./image.component.css'],
  animations: [
    trigger('fadeInOutAnimation', [
        state('in', style({
          opacity: 1,
          display: 'block'
        })),
        state('out', style({
          opacity: 0,
          display: 'none'
        })),
        transition('out => in', animate('250ms ease-in')),
        transition('in => out', animate('250ms ease-out'))
    ]),
  ]
})
export class ImageComponent implements OnInit, OnDestroy {

  private album: Array<any> = [];
  private _subscription: Subscription;
  private allowMultipleLikesPerUser: number = environment.allowMultipleLikesPerUser;

  @ViewChild('favourite') favourite;

  @Input() image: Image;
  id: string = '';
  likeColorDefault: string = '#ffffff';
  likeColor: string = '#b88be3';
  state: string = 'out';
  fbIcon = faFacebookSquare;
  tbrIcon = faTumblrSquare;
  tweetIcon = faTwitterSquare;
  linkedinInIcon = faLinkedinIn;
  likesSubscription: Subscription;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) document,
    private lightBox: Lightbox,
    private lightboxEvent: LightboxEvent,
    private renderer: Renderer2,
    private httpService: HttpService,
    private cookieService: CookieService,
    public fa: FontAwesomeModule) {

  }

  ngOnInit() {
    if(this.debug) {
      console.log('this.image.id: ', this.image.id);
    }  
    this.likesSubscription = this.httpService.fetchLikes(this.image.id).subscribe( (data: any) => {
      if(this.debug) {
        console.log('ngOnInit(): fetchLikes', data);
      }
      this.image.likes = data['likes'];
      if(this.image.likes) {
        this.likeColorDefault = '#b88be3';
      }
    });
  }

  openFile(src: string): void{   
    const album = {
      src: src
    };
    this.album.push(album);
    this.lightBox.open(this.album,0,{ disableScrolling: true, centerVertically: true, showImageNumberLabel: false });
    this.open();
    this.renderer.setStyle(
      document.body,
      'overflow',
      'hidden'
    );
  }

  share(event: any, id: string): void{   
    this.state = this.state === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  addLike(): void {

    const userToken = this.cookieService.get('userToken').toLowerCase();
      
    this.httpService.fetchLikes(this.image.id,1,userToken,this.allowMultipleLikesPerUser).subscribe( (data: any) => {
      if(this.debug) {
        console.log('addLike(): fetchLikes', data);
      }
      if(data['error'] === '') {
        this.image.likes = this.image.likes + 1;

        const el = document.querySelector('#favourite-' + this.image.id);
        const overshoot=5;
        const period=0.25;
        TweenMax.to(el,0.5,{
          scale:0.25,
          color:this.likeColor,
          onComplete:function(){
            TweenMax.to(el,1.4,{
              scale:1,
              ease:Elastic.easeOut,
              easeParams:[overshoot,period]
            })
          }
        });
      }
    });

  }

  open(): void {
    // register your subscription and callback whe open lightbox is fired
    if(this.debug) {
      console.log('LIGHTBOX: open');
    }
    this._subscription = this.lightboxEvent.lightboxEvent$
      .subscribe(event => this._onReceivedEvent(event));
  }
 
  private _onReceivedEvent(event: any): void {
    // remember to unsubscribe the event when lightbox is closed
    if (event.id === LIGHTBOX_EVENT.CLOSE) {
      // event CLOSED is fired
      if(this.debug) {
        console.log('LIGHTBOX_EVENT.CLOSE');
      }
      this._subscription.unsubscribe();
    }
 
    if (event.id === LIGHTBOX_EVENT.OPEN) {
      if(this.debug) {
        console.log('LIGHTBOX_EVENT.OPEN');
      }
      // event OPEN is fired
    }
 
    if (event.id === LIGHTBOX_EVENT.CHANGE_PAGE) {
      if(this.debug) {
        console.log('LIGHTBOX_EVENT.CHANGE_PAGE');
      }
      // event change page is fired
      if(this.debug) {
        console.log(event.data);
      }
    }
  }

  ngOnDestroy() {

    if (this.likesSubscription) {
      this.likesSubscription.unsubscribe();
    }

  }

}
