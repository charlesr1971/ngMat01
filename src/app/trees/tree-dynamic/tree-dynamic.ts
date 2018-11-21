import {CollectionViewer, SelectionChange} from '@angular/cdk/collections';
import {FlatTreeControl} from '@angular/cdk/tree';
import {Component, Injectable, OnInit, OnDestroy, Inject, ElementRef, ViewChild, Renderer2 } from '@angular/core';
import {BehaviorSubject, merge, Observable, Subject, Subscription} from 'rxjs';
import { debounceTime, distinctUntilChanged } from "rxjs/operators";
import {map} from 'rxjs/operators';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { DeviceDetectorService } from 'ngx-device-detector';
import { DOCUMENT } from '@angular/common'; 
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';
import { CookieService } from 'ngx-cookie-service';

import { HttpService } from '../../services/http/http.service';
import { UploadService } from '../../upload/upload.service';

import { User } from '../../user/user.model';

import { environment } from '../../../environments/environment';

declare var ease, TweenMax, Elastic: any;

/** Flat node with expandable and level information */

export class DynamicFlatNode {
  constructor(public item: string, public level = 1, public expandable = false,
              public isLoading = false, public alias: string) {}
}

/**
 * Database for dynamic data. When expanding a node in the tree, the data source will need to fetch
 * the descendants data from the database.
 */

@Injectable()
export class DynamicDatabase  {

  dataMap = new Map<string, string[]>();
  rootLevelNodes: string[] = ['//categories//objects', '//categories//nature', '//categories//other'];
  http: Observable<any>;
  httpService;

  debug: boolean = false;

  constructor(httpService: HttpService) {
    
    this.httpService = httpService;
    this.fetchData();

  }

  fetchData() {
    this.http = this.httpService.fetchDirectoryTree().subscribe( (data: any) => {
      this.dataMap = new Map<string, string[]>(data);
      if(this.debug) {
        console.log(this.dataMap);
      }
    });
  }

  /** Initial data from database */
  initialData(): DynamicFlatNode[] {
    return this.rootLevelNodes.map(name => new DynamicFlatNode(name, 0, true, false, this.pathFormat(name)));
  }

  getChildren(node: string): string[] | undefined {
    return this.dataMap.get(node);
  }

  isExpandable(node: string): boolean {
    return this.dataMap.has(node);
  }

  pathFormat(alias: string): any {
    let last:any = alias.split("//");
    last = Array.isArray(last) ? last[last.length-1] : alias;
    return last;
  }

}

/**
 * File database, it can build a tree structured Json object from string.
 * Each node in Json object represents a file or a directory. For a file, it has filename and type.
 * For a directory, it has filename and children (a list of files or directories).
 * The input will be a json object string, and the output is a list of `FileNode` with nested
 * structure.
 */

@Injectable()
export class DynamicDataSource {

  dataChange = new BehaviorSubject<DynamicFlatNode[]>([]);

  get data(): DynamicFlatNode[] { return this.dataChange.value; }
  set data(value: DynamicFlatNode[]) {
    this.treeControl.dataNodes = value;
    this.dataChange.next(value);
  }

  constructor(private treeControl: FlatTreeControl<DynamicFlatNode>,
              private database: DynamicDatabase) {}

  connect(collectionViewer: CollectionViewer): Observable<DynamicFlatNode[]> {
    this.treeControl.expansionModel.onChange!.subscribe(change => {
      if ((change as SelectionChange<DynamicFlatNode>).added ||
        (change as SelectionChange<DynamicFlatNode>).removed) {
        this.handleTreeControl(change as SelectionChange<DynamicFlatNode>);
      }
    });

    return merge(collectionViewer.viewChange, this.dataChange).pipe(map(() => this.data));
  }

  /** Handle expand/collapse behaviors */

  handleTreeControl(change: SelectionChange<DynamicFlatNode>) {
    if (change.added) {
      change.added.forEach(node => this.toggleNode(node, true));
    }
    if (change.removed) {
      change.removed.slice().reverse().forEach(node => this.toggleNode(node, false));
    }
  }

  /**
   * Toggle the node, remove from display list
   */

  toggleNode(node: DynamicFlatNode, expand: boolean) {
    const children = this.database.getChildren(node.item);
    const index = this.data.indexOf(node);
    if (!children || index < 0) { // If no children, or cannot find the node, no op
      return;
    }

    node.isLoading = true;

    setTimeout(() => {
      if (expand) {
        const nodes = children.map(name =>
          new DynamicFlatNode(name, node.level + 1, this.database.isExpandable(name), false, this.database.pathFormat(name)));
        this.data.splice(index + 1, 0, ...nodes);
      } else {
        let count = 0;
        for (let i = index + 1; i < this.data.length
          && this.data[i].level > node.level; i++, count++) {}
        this.data.splice(index + 1, count);
      }

      // notify the change
      this.dataChange.next(this.data);
      node.isLoading = false;
    }, 1000);
  }
}

/**
 * @title Tree with dynamic data
 */

@Component({
  selector: 'tree-dynamic',
  templateUrl: 'tree-dynamic.html',
  styleUrls: ['tree-dynamic.css'],
  providers: [DynamicDatabase]
})
export class TreeDynamic implements OnInit, OnDestroy {

  private userToken: string = '';

  @ViewChild('uploadedImageContainer') uploadedImageContainer;

  imagePath: string;
  selectedFile: File;
  directorySelected: string;
  treeForm: FormGroup;
  signUpForm: FormGroup;
  loginForm: FormGroup;
  name: FormControl;
  maxNameLength: number = 20;
  title: FormControl;
  maxTitleLength: number = 40;
  description: FormControl;
  maxDescriptionLength: number = 140;

  forename: FormControl;
  surname: FormControl;
  email: FormControl;
  password: FormControl;
  
  formData = {};
  ajaxUrl: string = '';

  treeControl: FlatTreeControl<DynamicFlatNode>;
  dataSource: DynamicDataSource;
  getLevel = (node: DynamicFlatNode) => node.level;
  isExpandable = (node: DynamicFlatNode) => node.expandable;
  hasChild = (_: number, _nodeData: DynamicFlatNode) => _nodeData.expandable;
  isMobile: boolean = false;
  hasError: boolean = false;
  signUpResponseDo: boolean = false;
  safeHtml: SafeHtml;
  isSignUpValid: boolean = false;
  isLoginValid: boolean = false;
  signUpValidated: number = 0;
  signupSubscription: Subscription;

  userid: number = 0;

  debug: boolean = false;

  constructor(@Inject(DOCUMENT) document, 
    database: DynamicDatabase, 
    private http: HttpClient,
    private httpService: HttpService,
    private uploadService: UploadService,
    private renderer: Renderer2,
    public el: ElementRef,
    private deviceDetectorService: DeviceDetectorService,
    private sanitizer: DomSanitizer,
    private cookieService: CookieService
    ) {

    this.ajaxUrl = environment.host + this.httpService.port + '/' + environment.cf_dir;

    this.treeControl = new FlatTreeControl<DynamicFlatNode>(this.getLevel, this.isExpandable);
    this.dataSource = new DynamicDataSource(this.treeControl, database);
    this.dataSource.data = database.initialData();
    this.isMobile = this.deviceDetectorService.isMobile();
    this.signUpValidated = this.httpService.signUpValidated;

  }

  ngOnInit() {

    this.createFormControls();
    this.createForm();

    if(this.treeForm) {

      this.name.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(name => {
          if(this.debug) {
            console.log('name: ',name);
          }
          this.formData['name'] = name;
          this.httpService.subjectImagePath.next(this.formData);
        });

      this.title.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(title => {
          if(this.debug) {
            console.log('title: ',title);
          }
          this.formData['title'] = title;
          this.httpService.subjectImagePath.next(this.formData);
        });

        this.description.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(description => {
          if(this.debug) {
            console.log('description: ',description);
          }
          this.formData['description'] = description;
          this.httpService.subjectImagePath.next(this.formData);
        });

      }

      if(this.signUpForm) {

        this.forename.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(forename => {
          if(this.debug) {
            console.log('forename: ',forename);
          }
          this.formData['forename'] = forename;
          this.isSignUpValid = this.isSignUpFormValid();
        });

        this.surname.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(surname => {
          if(this.debug) {
            console.log('surname: ',surname);
          }
          this.formData['surname'] = surname;
          this.isSignUpValid = this.isSignUpFormValid();
        });

      }

      if(this.signUpForm || this.loginForm) {

        this.email.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(email => {
          if(this.debug) {
            console.log('email: ',email);
          }
          this.formData['email'] = email;
          if(this.signUpForm) {
            this.isSignUpValid = this.isSignUpFormValid();
          }
          else{
            this.isLoginValid = this.isLoginFormValid();
          }
        });

        this.password.valueChanges
        .pipe(
          debounceTime(400),
          distinctUntilChanged()
        )
        .subscribe(password => {
          if(this.debug) {
            console.log('password: ',password);
          }
          this.formData['password'] = password;
          if(this.signUpForm) {
            this.isSignUpValid = this.isSignUpFormValid();
          }
          else{
            this.isLoginValid = this.isLoginFormValid();
          }
        });

      }

      this.uploadService.subscriptionImageError.subscribe( (data: any) => {
        if(this.debug) {
          console.log("tree-dynamic: subscriptionImageError: data", data);
        }
        this.toggleError(data);
      });

      this.uploadService.subscriptionImageUrl.subscribe( (data: any) => {
        if(this.debug) {
          console.log('tree.dynamic: data: ',data);
        }
        const uploadedImageContainer = this.uploadedImageContainer.nativeElement;
        const img = this.renderer.createElement('img');
        this.renderer.setAttribute(img,'src',data);
        this.renderer.setAttribute(img,'id','uploadedImage');
        const uploadedImage = document.getElementById('uploadedImage');
        if(uploadedImage) {
          this.renderer.removeChild(uploadedImageContainer,uploadedImage);
          if(this.debug) {
            console.log('tree.dynamic: remove image');
          }
        }
        
        this.renderer.appendChild(uploadedImageContainer,img);
        TweenMax.fromTo("#uploadedImage", 1, {scale:0, ease:Elastic.easeOut, opacity: 0}, {scale:1, ease:Elastic.easeOut, opacity: 1});
        if(this.debug) {
          console.log('tree.dynamic: add image');
        }

      });

      if(this.cookieService.check('userToken')) {
        this.userToken = this.cookieService.get( 'userToken' );
      }

      if(this.debug) {
        console.log('this.userToken',this.userToken);
      }

  }

  signUpFormSubmit() {
    const body = {
      forename: this.forename.value,
      surname: this.surname.value,
      email: this.email.value,
      password: this.password.value,
      userToken: this.userToken
    };
    console.log('signUp: body',body);
    this.signupSubscription = this.httpService.fetchSignUp(body).do(this.processSignUpData).subscribe();
  }

  private processSignUpData = (data) => {
    console.log('processSignUpData: data',data);
    this.signUpResponseDo = true;
  }

  loginFormSubmit() {
    const body = {
      email: this.email.value,
      password: this.password.value
    };
    console.log('login: body',body);
    this.signupSubscription = this.httpService.fetchLogin(body).do(this.processLoginData).subscribe();
  }

  private processLoginData = (data) => {
    console.log('processLoginData: data',data);
    this.userid = data['userid'];
    if(this.userid > 0) {
      this.createFormControls();
      this.createForm();
    }
  }

  isSignUpFormValid(): boolean {
    return this.forename.value != '' && this.surname.value != '' && this.email.value != '' && this.password.value != '' ? true : false;
  }

  isLoginFormValid(): boolean {
    return this.email.value != '' && this.password.value != '' ? true : false;
  }

  toggleError(error: string) {
    this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(error);
    this.hasError = error != '' ? true : false;
  }

  createFormControls() {
    this.name = new FormControl("", Validators.required);
    this.title = new FormControl("", Validators.required);
    this.description = new FormControl("", Validators.required);
    this.forename = new FormControl("", Validators.required);
    this.surname = new FormControl("", Validators.required);
    this.email = new FormControl("", Validators.required);
    this.password = new FormControl("", Validators.required);
    if(this.userid > 0) {
      this.name = new FormControl("", [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxNameLength)
      ]);
      this.title = new FormControl("", [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxTitleLength)
      ]);
      this.description = new FormControl("", [
        Validators.required,
        Validators.minLength(1),
        Validators.maxLength(this.maxDescriptionLength)
      ]);
    }
    else{
      if(this.userid == 0 && this.signUpValidated == 0) {
        this.forename = new FormControl("", [
          Validators.required,
          Validators.minLength(1)
        ]);
        this.surname = new FormControl("", [
          Validators.required,
          Validators.minLength(1)
        ]);
      }
      this.email = new FormControl("", [
        Validators.required,
        Validators.minLength(1)
      ]);
      this.password = new FormControl("", [
        Validators.required,
        Validators.minLength(1)
      ]);
    }
  }

  createForm() {
    if(this.userid > 0) {
      this.treeForm = new FormGroup({
        name: this.name,
        title: this.title,
        description: this.description
      });
    }
    else{
      if(this.userid == 0 && this.signUpValidated == 0) {
        this.signUpForm = new FormGroup({
          forename: this.forename,
          surname: this.surname,
          email: this.email,
          password: this.password
        });
      }
      else{
        this.loginForm = new FormGroup({
          email: this.email,
          password: this.password
        });
      }
    }
    console.log('this.treeForm ',this.treeForm);
    console.log('this.signUpForm ',this.signUpForm);
    console.log('this.loginForm ',this.loginForm);
  }

  addPath(event: any, item: string): void {
    const target = event.target || event.srcElement || event.currentTarget;
    if(this.debug) {
      console.log('addPath: target: ',target);
    }
    if(this.debug) {
      console.log('addPath: item: ',item);
      console.log('addPath: item: ',item);
    }
    this.imagePath = item;
    this.formData['imagePath'] = this.imagePath;
    this.formData['userToken'] = this.userToken;
    this.httpService.subjectImagePath.next(this.formData);
    this.directorySelected = this.imagePath;
    const gradeEl = document.getElementById('directory-' + this.pathFormat(this.imagePath));
    if(this.debug) {
      console.log('addPath: gradeEl: ',gradeEl);
    }
    TweenMax.fromTo(gradeEl, 1, {scale:0, ease:Elastic.easeOut, opacity: 0, rotation: 1}, {scale:1, ease:Elastic.easeOut, opacity: 1, rotation: 359});
  }

  previewImage(event) {
    this.selectedFile = event.target.files[0];
    if(this.debug) {
      console.log('onFileChanged: this.selectedFile: ',this.selectedFile);
    }
    this.onUpload();
  }

  onUpload() {

    let fileExtension: any = this.selectedFile.type.split("/");
    fileExtension = Array.isArray(fileExtension) ? fileExtension[fileExtension.length-1] : "";

    const httpOptions = {
      headers: new HttpHeaders({
        'Image-path':  this.imagePath,
        'File-Extension': fileExtension,
        'User-Token': this.userToken
      })
    };

    if(this.debug) {
      console.log('onUpload: httpOptions: ',httpOptions);
    }

    this.http.post(this.ajaxUrl + '/upload-image.cfm', this.selectedFile, httpOptions).pipe(map(
      (res: Response) => {
        if(this.debug) {
          console.log(res);
        }
        return res;
      })
    ).subscribe( (data: any) => {
      if(this.debug) {
        console.log('onUpload: data: ',data);
      }
    });

  }

  pathFormat(value: any): any {
    let last = value.split("//");
    last = Array.isArray(last) ? last[last.length-1] : value;
    return last;
  }

  stringFromUTF8Array(data)
  {
    const extraByteMap = [ 1, 1, 1, 1, 2, 2, 3, 0 ];
    var count = data.length;
    var str = "";
    
    for (var index = 0;index < count;)
    {
      var ch = data[index++];
      if (ch & 0x80)
      {
        var extra = extraByteMap[(ch >> 3) & 0x07];
        if (!(ch & 0x40) || !extra || ((index + extra) > count))
          return null;
        
        ch = ch & (0x3F >> extra);
        for (;extra > 0;extra -= 1)
        {
          var chx = data[index++];
          if ((chx & 0xC0) != 0x80)
            return null;
          
          ch = (ch << 6) | (chx & 0x3F);
        }
      }
      
      str += String.fromCharCode(ch);
    }
    
    return str;
  }

  ngOnDestroy() {

    if (this.signupSubscription) {
      this.signupSubscription.unsubscribe();
    }

  }

}
