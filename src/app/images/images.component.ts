import { Component, OnInit, OnDestroy, Input, Inject, HostListener, ViewChild, Renderer2, ElementRef } from '@angular/core';

import { HttpService } from '../services/http/http.service';
import { Image } from './../image/image.model';
import { Observable } from '../../../node_modules/rxjs';

import { environment } from '../../environments/environment';

@Component({
  selector: 'app-images',
  templateUrl: './images.component.html',
  styleUrls: ['./images.component.css']
})
export class ImagesComponent implements OnInit, OnDestroy {

  @ViewChild('infiniteScrollerContainer') infiniteScrollerContainer: ElementRef;

  images: Array<any> = [];
  currentPage: number = 1;
  scrollCallback;
  screenHeight: number = 0;
  screenWidth: number = 0;
  toolbarHeight: number = 64;
  ajaxUrl: string = '';

  debug: boolean = false;

  constructor(private httpService: HttpService,
    private renderer: Renderer2) { 

    this.ajaxUrl = environment.host + this.httpService.port + '/' + environment.cf_dir;

    this.onResize();
    this.scrollCallback = this.fetchData.bind(this);

    this.httpService.galleryPage.subscribe( (page) => {
      if(page > 0) {
        this.images = [];
        this.currentPage = page;
        if(this.debug) {
          console.log('images.component: galleryPage.subscribe: this.currentPage: ', this.currentPage);
        }
        this.httpService.fetchImages(this.currentPage).do(this.processData).subscribe();
      }
    });

  }

  ngOnInit() {
    
  }

  @HostListener('window:resize', ['$event']) onResize(event?) {
    this.screenHeight = window.innerHeight;
    if(this.debug) {
      console.log('his.screenHeight',this.screenHeight);
    }
    this.screenWidth = window.innerWidth;
    if(this.debug) {
      console.log('this.screenWidth',this.screenWidth);
    }
    setTimeout( () => {
      if(this.screenHeight > 0) {
        this.renderer.setStyle(
          this.infiniteScrollerContainer.nativeElement,
          'height',
          (this.screenHeight - this.toolbarHeight) + 'px'
        );
      }
    })
  }

  fetchData(): Observable<any> {
    if(this.debug) {
      console.log('images.component: fetchData()');
    }
    return this.httpService.fetchImages(this.currentPage).do(this.processData);
  }

  private processData = (data) => {
    this.currentPage++;
    if(this.debug) {
      console.log('this.currentPage',this.currentPage);
    }
    data.map( (item: any) => {
      const image = new Image({
        id: item['fileUuid'],
        category: item['category'],
        src: this.ajaxUrl + '/' + item['src'],
        author: item['author'],
        title: item['title'],
        description: item['description'],
        size: item['size'],
        likes: item['likes'],
        userToken: item['userToken'],
        createdAt: item['createdAt']
      });
      this.images.push(image);
    });
    this.images.sort(function(a, b) {
      const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
      return dateB - dateA;
    });
    if(this.debug) {
      console.log('this.images: ', this.images);
    }
  }

  ngOnDestroy() {

  }

}
