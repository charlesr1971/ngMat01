
import { Injectable } from '@angular/core';
import { HttpClient, HttpRequest, HttpEventType, HttpResponse, HttpHeaders } from '@angular/common/http';
import { Subject } from 'rxjs/Subject';
import { Observable } from 'rxjs/Observable';

import { HttpService } from '../services/http/http.service';

import { environment } from '../../environments/environment';

//const url = environment.host + this.httpService.port + '/' + environment.cf_dir + '/upload-image.cfm';

@Injectable()
export class UploadService {

  imagePath: string;
  name: string;
  title: string;
  description: string;
  userToken: string = '';
  ajaxUrl: string = '';

  subscriptionImageError: Subject<any> = new Subject<any>();
  subscriptionImageUrl: Subject<any> = new Subject<any>();

  debug: boolean = false;

  constructor(private http: HttpClient, 
    private httpService: HttpService) {

    this.ajaxUrl = environment.host + this.httpService.port + '/' + environment.cf_dir;

    this.httpService.subjectImagePath.subscribe( (data: any) => {
      if(this.debug) {
        console.log('upload.service: data: ',data);
      }
      this.imagePath = data['imagePath'];
      this.name = data['name'];
      this.title = data['title'];
      this.description = data['description'];
      this.userToken = data['userToken'];
    });

  }

  public upload(files: Set<File>): {[key:string]:Observable<number>} {
    // this will be the our resulting map
    const status = {};

    files.forEach(file => {
      // create a new multipart-form for every file
      const formData: FormData = new FormData();
      formData.append('file', file, file.name);

      if(this.debug) {
        console.log('upload: file ',file);
      }

      let fileExtension: any = file.type.split("/");
      fileExtension = Array.isArray(fileExtension) ? fileExtension[fileExtension.length-1] : "";

      const httpOptions = {
        reportProgress: true,
        headers: new HttpHeaders({
          'File-Name':  file.name,
          'Image-Path':  this.imagePath,
          'Name': this.name,
          'Title': this.title,
          'Description': this.description,
          'File-Extension': fileExtension,
          'User-Token': this.userToken
        })
      };

      // create a http-post request and pass the form
      // tell it to report the upload progress

      const req = new HttpRequest('POST', this.ajaxUrl + '/upload-image.cfm', file, httpOptions);

      // create a new progress-subject for every file
      const progress = new Subject<number>();

      // send the http-request and subscribe for progress-updates
      this.http.request(req).subscribe(event => {

        if (event.type === HttpEventType.UploadProgress) {

          // calculate the progress percentage
          const percentDone = Math.round(100 * event.loaded / event.total);

          // pass the percentage into the progress-stream
          progress.next(percentDone);
        } else if (event instanceof HttpResponse) {

          // Close the progress-stream if we get an answer form the API
          // The upload is complete
          if(this.debug) {
            console.log('upload: event ',event);
          }

          if('error' in event.body && event.body['error'] != '') {
            this.subscriptionImageError.next(event.body['error']);
          }
          else{
            if('imagePath' in event.body && event.body['imagePath'] != '') {
              this.subscriptionImageUrl.next(this.ajaxUrl + '/' + event.body['imagePath']);
            }
          }

          progress.complete();

        }
        
      });

      // Save every progress-observable in a map of all observables
      status[file.name] = {
        progress: progress.asObservable()
      };
    });

    // return the map of progress.observables
    return status;
  }

}
